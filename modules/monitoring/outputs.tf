output "ec2_instance_id" {
  description = "ID of the monitored EC2 instance"
  value       = aws_instance.monitored_instance.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.monitored_instance.public_ip
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.monitored_instance.private_ip
  sensitive   = true
}

output "health_alarm_arn" {
  description = "ARN of the instance health recovery alarm"
  value       = aws_cloudwatch_metric_alarm.instance_health.arn
}

output "security_alerts_topic_arn" {
  description = "ARN of the SNS topic for security alerts"
  value       = aws_sns_topic.security_alerts.arn
}

output "ssh_monitoring_metric_filter" {
  description = "Details of the SSH monitoring metric filter"
  value       = {
    name           = aws_cloudwatch_log_metric_filter.ssh_failures.name
    log_group_name = aws_cloudwatch_log_metric_filter.ssh_failures.log_group_name
    pattern        = aws_cloudwatch_log_metric_filter.ssh_failures.pattern
  }
}

output "security_audit_role_arn" {
  description = "ARN of the security audit IAM role"
  value       = aws_iam_role.security_audit.arn
}


output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "incident_response_runbook" {
  description = "Details of the SSM Incident Response document"
  value       = {
    name    = aws_ssm_document.incident_response.name
    version = aws_ssm_document.incident_response.latest_version
    arn     = aws_ssm_document.incident_response.arn
  }
}

output "troubleshooting_guide" {
  description = "How to access the troubleshooting guide"
  value       = "Access the runbook in AWS Systems Manager > Documents > IncidentResponseRunbook"
}

output "flow_logs_group_name" {
  description = "Name of the VPC Flow Logs CloudWatch group"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "cloudtrail_bucket_name" {
  description = "Name of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.bucket
  sensitive   = true
}

output "auth_logs_group" {
  description = "Authentication logs CloudWatch Logs group details"
  value = {
    name = aws_cloudwatch_log_group.auth_logs.name
    arn  = aws_cloudwatch_log_group.auth_logs.arn
  }
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "security_hub_status" {
  description = "Security Hub enablement status"
  value       = aws_securityhub_account.main.enable_default_standards ? "Enabled with defaults" : "Enabled"
}

output "notification_subscription_instructions" {
  description = "How to subscribe to security alerts"
  value       = <<EOT
To receive security alerts, subscribe to the SNS topic using:
aws sns subscribe \
  --topic-arn ${aws_sns_topic.security_alerts.arn} \
  --protocol email \
  --notification-endpoint your-email@example.com
EOT
}

output "kms_key_arn" {
  description = "ARN of KMS key used for log encryption"
  value       = aws_kms_key.logs_key.arn
  sensitive   = true
}