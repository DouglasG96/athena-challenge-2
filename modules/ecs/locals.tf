locals {
  ecs_vars = [
    for key, value in var.environment_vars :
    {
      name  = key
      value = value
    }
  ]

  container_definitions = jsonencode([
    {
      name        = "${var.project_name}-container"
      image       = var.container_image
      cpu         = var.container_cpu
      memory      = var.container_memory
      environment = local.ecs_vars
      secrets     = var.secrets
      essential   = true
      portMappings = [
        {
          protocol      = "tcp"
          appProtocol   = "http"
          containerPort = var.container_port
          hostPort      = var.container_port
          name          = "${var.project_name}-port"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}