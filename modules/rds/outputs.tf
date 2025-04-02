output "cluster_identifier" {
  description = "The Aurora Cluster Identifier"
  value       = aws_rds_cluster.aurora_mysql.cluster_identifier
}

output "cluster_endpoint" {
  description = "The writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.aurora_mysql.endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value       = aws_rds_cluster.aurora_mysql.reader_endpoint
}

output "cluster_port" {
  description = "The database port"
  value       = aws_rds_cluster.aurora_mysql.port
}

output "database_name" {
  description = "The name of the database"
  value       = aws_rds_cluster.aurora_mysql.database_name
}

output "master_username" {
  description = "The master username for the database"
  value       = aws_rds_cluster.aurora_mysql.master_username
  sensitive   = true
}

output "security_group_id" {
  description = "The security group ID of the RDS cluster"
  value       = aws_security_group.rds_sg.id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "instance_endpoints" {
  description = "List of instance endpoints"
  value       = aws_rds_cluster_instance.aurora_mysql_instances[*].endpoint
}

output "arn" {
  description = "The ARN of the Aurora cluster"
  value       = aws_rds_cluster.aurora_mysql.arn
}

output "secret_arn"{
  description = "The ARN of the secret for the Aurora cluster"
  value = aws_secretsmanager_secret.db_credentials.arn
}