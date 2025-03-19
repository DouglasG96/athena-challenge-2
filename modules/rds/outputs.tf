output "rds_endpoint" { value = aws_db_instance.rds.endpoint }
output "rds_username" { value = aws_db_instance.rds.username }
output "rds_password" { value = aws_db_instance.rds.password }
output "rds_db_name" { value = aws_db_instance.rds.db_name }
output "rds_port" { value = aws_db_instance.rds.port }