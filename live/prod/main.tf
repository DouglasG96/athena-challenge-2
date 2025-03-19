module "vpc" {
  source          = "../../modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "alb" {
  source = ".../../modules/alb"
  #   vpc_id        = module.vpc.vpc_id
  #   public_subnets = module.vpc.public_subnets
  #   waf_enabled   = true
}

module "ecs" {
  source = "../../modules/ecs"
  #   vpc_id         = module.vpc.vpc_id
  #   cluster_name   = var.ecs_cluster_name
  #   alb_target_group_arn = module.alb.target_group_arn
}

module "ecr" {
  source = "../../modules/ecr"
  #   vpc_id         = module.vpc.vpc_id
  #   cluster_name   = var.ecs_cluster_name
  #   alb_target_group_arn = module.alb.target_group_arn
}

module "rds" {
  source = "../../modules/rds"
  #   vpc_id          = module.vpc.vpc_id
  #   private_subnets = module.vpc.private_subnets
  #   db_username     = var.db_username
  #   db_password     = var.db_password
}

module "security" {
  source = "../../modules/security"
}

module "monitoring" {
  source = "../../modules/monitoring"
}