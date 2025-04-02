resource "aws_ecs_cluster" "athena_ecs_cluster" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_ecs_service" "athena_ecs_service" {
  name                    = "${var.project_name}-ecs-service"
  cluster                 = aws_ecs_cluster.athena_ecs_cluster.id
  task_definition         = aws_ecs_task_definition.athena_ecs_task_definition.arn
  desired_count           = var.desired_count
  enable_ecs_managed_tags = var.enable_exec
  launch_type             = "FARGATE"
  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.alb_target_group != null ? [var.alb_target_group] : []
    content {
      target_group_arn = load_balancer.value
      container_name   = "${var.project_name}-container"
      container_port   = var.container_port
    }
  }
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_namespace.arn
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "ECS service security group"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = var.alb_security_groups != null ? var.alb_security_groups : []
    cidr_blocks     = var.alb_security_groups == null ? ["0.0.0.0/0"] : []
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

resource "aws_service_discovery_http_namespace" "service_namespace" {
  name = var.project_name
  description = "Service discovery namespace for ${var.project_name}"
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "athena_ecs_task_definition" {
  family                = "${var.project_name}-task"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  cpu = var.container_cpu
  memory = var.container_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions = local.container_definitions
  depends_on = [aws_cloudwatch_log_group.ecs_logs]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = var.desired_count
  resource_id        = "service/${aws_ecs_cluster.athena_ecs_cluster.name}/${aws_ecs_service.athena_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.project_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "${var.project_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  # alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.athena_ecs_cluster.name
    ServiceName = aws_ecs_service.athena_ecs_service.name
  }
}

resource "aws_iam_policy" "ecs_logs_policy" {
  name        = "${var.project_name}-ecs-logs-policy"
  description = "Allow ECS to create log streams and put log events"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}:*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_logs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_logs_policy.arn
}

data "aws_caller_identity" "current" {}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days  # Adjust retention as needed
  tags = {
    Name = "${var.project_name}-ecs-logs"
  }
}

resource "aws_iam_policy" "secrets_access" {
  name        = "${var.project_name}-secrets-access"
  description = "Allow ECS to read database credentials"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      Resource = [
        var.db_credentials_arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}