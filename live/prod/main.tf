module "vpc" {
  source          = "../../modules/vpc"
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "alb" {
  source             = "../../modules/alb"
  project_name       = var.project_name
  internal_alb       = var.internal_alb
  load_balancer_type = var.load_balancer_type
  public_subnets     = module.vpc.public_subnet_ids
  alb_port           = var.alb_port
  container_port     = var.container_port
  # access_logs        = var.access_logs
  vpc_id = module.vpc.vpc_id
  scope  = var.scope
  depends_on = [
    module.vpc
  ]
}


module "ecs" {
  source              = "../../modules/ecs"
  project_name        = var.project_name
  container_image     = module.ecr.repository_url
  container_cpu       = var.container_cpu
  container_memory    = var.container_memory
  container_port      = var.container_port
  aws_region          = var.aws_region
  desired_count       = var.desired_count
  enable_exec         = var.enable_exec
  assign_public_ip    = var.assign_public_ip
  alb_target_group    = module.alb.target_group_arn
  alb_security_groups = module.alb.alb_security_group_id
  private_subnets     = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  log_retention_days  = var.log_retention_days
  db_credentials_arn  = module.rds.secret_arn
  environment_vars = {
    "DB_HOST" : module.rds.cluster_endpoint
  }
  secrets = [
    {
      name      = "DB_PORT"
      valueFrom = "${module.rds.secret_arn}:DB_PORT::"
    },
    {
      name      = "DB_USER"
      valueFrom = "${module.rds.secret_arn}:DB_USER::"
    },
    {
      name      = "DB_PASSWORD"
      valueFrom = "${module.rds.secret_arn}:DB_PASSWORD::"
    },
    {
      name      = "DB_NAME"
      valueFrom = "${module.rds.secret_arn}:DB_NAME::"
    },
  ]

  depends_on = [
    module.ecr,
    module.alb
  ]
}

module "ecr" {
  source               = "../../modules/ecr"
  project_name         = var.project_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
}

module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnet_ids
  db_username           = var.db_username
  db_password           = var.db_password
  ecs_security_group_id = module.ecs.ecs_security_group_id
  cluster_instances     = var.cluster_instances
}

module "monitoring" {
  source        = "../../modules/monitoring"
  project_name  = var.project_name
  email_address = var.email_address
  public_subnet = module.vpc.public_subnet_ids[0]
  aws_region    = var.aws_region
  vpc_id        = module.vpc.vpc_id
}