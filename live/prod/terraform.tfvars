#AWS

aws_region  = "us-east-1"
aws_profile = "default"
environment = "prod"

# ECS

project_name       = "athena"
container_cpu      = 256
container_memory   = 512
container_port     = 80
desired_count      = 1
enable_exec        = true
assign_public_ip   = false
alb_target_group   = ""
log_retention_days = 30

# ECR

image_tag_mutability = "MUTABLE"
force_delete         = true

# VPC

vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
cidr_block      = "0.0.0.0/0"

# ALB

alb_port           = "80"
load_balancer_type = "application"
internal_alb       = false
# access_logs        = ""
scope = "REGIONAL"

# RDS

db_username       = "athena"
db_password       = "athena123"
cluster_instances = 2

# Monitoring

email_address = "drgb96@gmail.com"
public_subnet = ""