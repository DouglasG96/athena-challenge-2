output "vpc_id" { value = module.vpc.vpc_id }
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "ecs_cluster_id" { value = module.ecs.ecs_cluster_id }
output "rds_endpoint" { value = module.rds.rds_endpoint }
output "rds_username" { value = module.rds.rds_username }
output "rds_password" { value = module.rds.rds_password }
output "rds_db_name" { value = module.rds.rds_db_name }
output "rds_port" { value = module.rds.rds_port }