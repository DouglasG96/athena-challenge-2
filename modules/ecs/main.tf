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
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.alb_target_group != null ? [var.alb_target_group] : []
    content {
      target_group_arn = load_balancer.value
      container_name   = var.project_name
      container_port   = var.container_port
    }
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.project_name
  }
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
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "athena_ecs_task_definition" {
  family                = "${var.project_name}-task"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role
  container_definitions = local.container_definitions
}