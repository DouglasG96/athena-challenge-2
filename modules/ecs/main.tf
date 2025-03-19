resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_service" "app" {
  name = "app-service"
  cluster = aws_ecs_cluster.main.id
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }
}
