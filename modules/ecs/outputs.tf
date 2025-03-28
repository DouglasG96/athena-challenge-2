output "ecs_cluster_id" { value = aws_ecs_cluster.athena_ecs_cluster.id }
output "ecs_cluster_name" { value = aws_ecs_cluster.athena_ecs_cluster.name }
output "ecs_cluster_service_id" { value = aws_ecs_service.athena_ecs_service.id }
output "ecs_cluster_service_name" { value = aws_ecs_service.athena_ecs_service.name }
output "logs_groups" { value = "/ecs/${var.project_name}"}