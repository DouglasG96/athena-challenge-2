#VPC 
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = [module.vpc.public_route_table_ids]
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "azs" {
  description = "List of Availability Zones used"
  value       = var.azs
}

#ECS

# output "ecs_cluster_id" { value = aws_ecs_cluster.athena_ecs_cluster.id }
# output "ecs_cluster_name" { value = aws_ecs_cluster.athena_ecs_cluster.name }
# output "ecs_cluster_service_id" { value = aws_ecs_service.athena_ecs_service.id }
# output "ecs_cluster_service_name" { value = aws_ecs_service.athena_ecs_service.name }
# output "logs_groups" { value = "/ecs/${var.project_name}" }

# ECR 
# output "repository_url" {
#   description = "The URL of the created ECR repository"
#   value       = aws_ecr_repository.this.repository_url
# }

# output "repository_arn" {
#   description = "The ARN of the created ECR repository"
#   value       = aws_ecr_repository.this.arn
# }