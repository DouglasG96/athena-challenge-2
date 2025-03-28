locals {
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = var.container_image
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
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
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}