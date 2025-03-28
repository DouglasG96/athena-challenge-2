#VPC 
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = [aws_route_table.public.id]
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nat[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "azs" {
  description = "List of Availability Zones used"
  value       = var.azs
}

#ECS

output "ecs_cluster_id" { value = aws_ecs_cluster.athena_ecs_cluster.id }
output "ecs_cluster_name" { value = aws_ecs_cluster.athena_ecs_cluster.name }
output "ecs_cluster_service_id" { value = aws_ecs_service.athena_ecs_service.id }
output "ecs_cluster_service_name" { value = aws_ecs_service.athena_ecs_service.name }
output "logs_groups" { value = "/ecs/${var.project_name}" }

# ECR 
output "repository_url" {
  description = "The URL of the created ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "The ARN of the created ECR repository"
  value       = aws_ecr_repository.this.arn
}