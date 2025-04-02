resource "aws_instance" "monitored_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.monitoring_profile.name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id     = var.public_subnet

   user_data = <<-EOF
              #!/bin/bash
              # Install and configure CloudWatch agent
              sudo apt-get update -y
              sudo apt-get install -y amazon-cloudwatch-agent

              # Create CloudWatch agent config
              cat > /tmp/cw-agent-config.json <<'EOC'
              {
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/var/log/auth.log",
                          "log_group_name": "${aws_cloudwatch_log_group.auth_logs.name}",
                          "log_stream_name": "{instance_id}",
                          "timezone": "UTC"
                        }
                      ]
                    }
                  }
                }
              }
              EOC

              # Start CloudWatch agent with new config
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -c file:/tmp/cw-agent-config.json \
                -s
              EOF

  tags = {
    Name = "${var.project_name}-monitored-instance"
  }
  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_iam_role" "monitoring_role" {
  name = "${var.project_name}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.project_name}-monitoring-profile"
  role = aws_iam_role.monitoring_role.name
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}

resource "aws_cloudtrail" "audit_trail" {
  name                          = "${var.project_name}-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ec2/${aws_instance.monitored_instance.id}/application"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_metric_filter" "error_logs" {
  name           = "${var.project_name}-error-logs"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.app_logs.name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "Application"
    value     = "1"
  }
}

data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com/" # A service that returns your public IP
}

locals {
  my_ip = "${chomp(data.http.my_public_ip.response_body)}/32"
}


resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-monitored-instance-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = var.vpc_id


    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip] # Allow MYSQL only from your current IP
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-system-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.project_name}-cloudtrail-logs-${random_id.bucket_suffix.hex}"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.project_name}-cloudtrail-logs"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AWSCloudTrailAclCheck",
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      },
      Action   = "s3:GetBucketAcl",
      Resource = aws_s3_bucket.cloudtrail.arn
    },
    {
      Sid    = "AWSCloudTrailWrite",
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      },
      Action   = "s3:PutObject",
      Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }]
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "flow_log_role" {
  name = "${var.project_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.project_name}-flow-log-policy"
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc-flow-logs/${var.project_name}"
  retention_in_days = 30
  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

# CloudWatch Alarm for Status Check Failed
resource "aws_cloudwatch_metric_alarm" "instance_health" {
  alarm_name          = "${var.project_name}-instance-health-check"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Trigger recovery when system status check fails for 2 consecutive minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn, "arn:aws:automate:${var.aws_region}:ec2:recover"]

  dimensions = {
    InstanceId = aws_instance.monitored_instance.id
  }
}

# Unauthorized SSH Attempts Alarm
resource "aws_cloudwatch_metric_alarm" "ssh_attempts" {
  alarm_name          = "${var.project_name}-unauthorized-ssh-attempts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SSHAttempts"
  namespace           = "Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alerts on multiple failed SSH attempts"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  depends_on = [aws_cloudwatch_log_metric_filter.ssh_failures]
}

# Metric Filter for SSH Failures
resource "aws_cloudwatch_log_metric_filter" "ssh_failures" {
  name           = "ssh-failure-events"
  pattern        = "[timestamp, ip, user, password, status, method, version=\"*\", reason=\"*\", ...]"
  log_group_name = aws_cloudwatch_log_group.auth_logs.name

  metric_transformation {
    name      = "SSHAttempts"
    namespace = "Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_group" "auth_logs" {
  name              = "/${var.project_name}/auth"
  retention_in_days = 90  # Keep logs for 3 months
  kms_key_id        = aws_kms_key.logs_key.arn  # Optional encryption

  tags = {
    Name        = "${var.project_name}-auth-logs"
  }
}

# Optional KMS Key for log encryption
resource "aws_kms_key" "logs_key" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_logs_policy.json
}

data "aws_iam_policy_document" "kms_logs_policy" {
  # Allow root account full access (required for future policy updates)
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow CloudWatch Logs to use the key
  statement {
    sid    = "EnableCloudWatchLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}

# Security Alerts SNS Topic
resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts"
}

resource "aws_sns_topic_policy" "security_alerts" {
  arn    = aws_sns_topic.security_alerts.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    resources = [aws_sns_topic.security_alerts.arn]
  }
}

# Incident Response Runbook
resource "aws_ssm_document" "incident_response" {
  name          = "${var.project_name}-IncidentResponseRunbook"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Critical Failure Response Guide"
    parameters = {
      instanceId = {
        type        = "String"
        description = "The instance ID to investigate"
      }
    }
    mainSteps = [{
      action = "aws:runShellScript",
      name   = "DiagnoseFailure",
      inputs = {
        runCommand = [
          "echo '1. Check CloudWatch Logs: /var/log/syslog'",
          "echo '2. Verify instance status: aws ec2 describe-instance-status --instance-id {{instanceId}}'",
          "echo '3. Review security groups and NACLs'",
          "echo '4. Check for unauthorized SSH attempts in auth.log'"
        ]
      }
    }]
  })
}

# IAM Access Analyzer
resource "aws_accessanalyzer_analyzer" "account_analyzer" {
  analyzer_name = "${var.project_name}-account-analyzer"
  type          = "ACCOUNT"
}

# IAM Policy for Audit Role
resource "aws_iam_role" "security_audit" {
  name = "${var.project_name}-SecurityAuditRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      Action = "sts:AssumeRole",
      Condition = {
        Bool = {
          "aws:MultiFactorAuthPresent" = "true"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "security_audit" {
  role       = aws_iam_role.security_audit.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# Config Rule for IAM Best Practices
resource "aws_config_config_rule" "iam_best_practices" {
  name = "${var.project_name}-iam-best-practices"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# GuardDuty for Threat Detection
resource "aws_guardduty_detector" "main" {
  enable = true
}

# Security Hub for Comprehensive View
resource "aws_securityhub_account" "main" {}

# AWS Config for Compliance Tracking
resource "aws_config_configuration_recorder" "main" {
  name     = "main"
  role_arn = aws_iam_role.config.arn
}

resource "aws_iam_role" "config" {
  name = "${var.project_name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_iam_role_policy" "logs_encryption" {
  name   = "${var.project_name}-logs-encryption-policy"
  role   = aws_iam_role.monitoring_role.name
  policy = data.aws_iam_policy_document.logs_encryption.json
}

data "aws_iam_policy_document" "logs_encryption" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.logs_key.arn]
  }
}