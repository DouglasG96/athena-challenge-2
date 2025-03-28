variable "aws_region" { default = "us-east-1" }
variable "aws_profile" { default = "athena" }
variable "environment" { default = "prod" }
variable "project_name" {
  default = "athena"
  type    = string
}
# ECS
# variable "container_image" { type = string }
# variable "container_cpu" {
#   type        = number
#   default     = 256
#   description = "cpu for the ECS container"
# }
# variable "container_memory" {
#   type        = number
#   default     = 512
#   description = "memory for the ECS container"
# }

# variable "container_port" {
#   type        = number
#   default     = 80
#   description = "value for the container port"
# }

# variable "desired_count" {
#   type        = number
#   default     = 1
#   description = "desired count for the ECS service"
# }

# variable "enable_exec" {
#   type        = bool
#   default     = false
#   description = "enable command execution for the ECS service"
# }
# variable "security_groups" {
#   type        = list(string)
#   description = "security groups for the ECS service"
# }
# variable "assign_public_ip" {
#   type        = bool
#   default     = false
#   description = "assign public ip for the ECS service"
# }

# variable "alb_target_group" {
#   type        = string
#   description = "target group for the ECS service"
# }

variable "private_subnets" { type = list(string) }
# variable "ecs_service_name" {
#   type = string
# }

# ECR

# variable "image_tag_mutability" {
#   description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
#   type        = string
#   default     = "MUTABLE"
# }

# variable "force_delete" {
#   description = "If true, the repository will be deleted even if it contains images"
#   type        = bool
#   default     = false
# }
# VPC

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "0.0.0.0/0"
}

# ALB

# variable "alb_port" {
#   type = number
# }

# variable "load_balancer_type" {
#   type    = string
#   default = "application"
# }
# variable "internal_alb" {
#   type    = bool
#   default = false
# }

# variable "access_logs" {
#   type = list(any)
# }
# variable "vpc_id" {}
# variable "scope" { type = string }