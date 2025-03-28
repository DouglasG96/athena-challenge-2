module "vpc" {
  source          = "../../modules/vpc"
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "alb" {
  source = ".../../modules/alb"
  name               = "${var.project_name}-alb"
  internal           = var.internal_alb
  load_balancer_type = var.load_balancer_type
  public_subnets     = module.vpc.public_subnet_ids
  alb_port           = var.alb_port
  access_logs        = var.access_logs
  vpc_id             = module.vpc.vpc_id
  alb_sg             = var.alb_sg
}

resource "aws_service_discovery_http_namespace" "service_namespace" {
  name = var.project_name
}
module "ecs" {
  source           = "../../modules/ecs"
  project_name     = var.project_name
  container_image  = module.ecr.repository_url
  container_cpu    = var.container_cpu
  container_memory = var.container_memory
  container_port   = var.container_port
  aws_region       = var.aws_region
  desired_count    = var.desired_count
  enable_exec      = var.enable_exec
  security_groups  = var.security_groups
  assign_public_ip = var.assign_public_ip
  alb_target_group = var.alb_target_group
  private_subnets  = module.vpc.private_subnet_ids

  depends_on = [
    module.ecr,
    module.alb,
    aws_service_discovery_http_namespace.service_namespace
  ]
}

module "ecr" {
  source               = "../../modules/ecr"
  project_name         = var.project_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
}

# module "rds" {
#   source = "../../modules/rds"
#   vpc_id          = module.vpc.vpc_id
#   private_subnets = module.vpc.private_subnets
#   db_username     = var.db_username
#   db_password     = var.db_password
# }

# module "security" {
#   source = "../../modules/security"
# }

# module "monitoring" {
#   source = "../../modules/monitoring"
# }