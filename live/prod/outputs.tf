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

output "ecs_cluster_id" { value = module.ecs.ecs_cluster_id }
output "ecs_cluster_name" { value = module.ecs.ecs_cluster_name }
output "ecs_cluster_service_id" { value = module.ecs.ecs_cluster_service_id }
output "ecs_cluster_service_name" { value = module.ecs.ecs_cluster_service_name }
output "logs_groups" { value = "/ecs/${var.project_name}" }

# ECR 
output "repository_url" {
  description = "The URL of the created ECR repository"
  value       = module.ecr.repository_url
}
output "repository_arn" {
  description = "The ARN of the created ECR repository"
  value       = module.ecr.repository_arn
}

# RDS
output "rds_cluster_id" {
  description = "The Aurora Cluster Identifier"
  value       = module.rds.cluster_identifier
}
output "rds_cluster_endpoint" {
  description = "The writer endpoint for the Aurora cluster"
  value       = module.rds.cluster_endpoint
}
output "rds_cluster_reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value       = module.rds.cluster_reader_endpoint
}
output "rds_cluster_port" {
  description = "The database port"
  value       = module.rds.cluster_port
}
output "rds_database_name" {
  description = "The name of the database"
  value       = module.rds.database_name
}
output "rds_master_username" {
  description = "The master username for the database"
  value       = module.rds.master_username
  sensitive   = true
}
output "rds_security_group_id" {
  description = "The security group ID of the RDS cluster"
  value       = module.rds.security_group_id
}