variable "project_name" {
  type    = string
  default = "athena"
}
variable "container_image" {
  type    = string
  default = ""
}
variable "container_cpu" {
  type        = number
  default     = 256
  description = "cpu for the ECS container"
}
variable "container_memory" {
  type        = number
  default     = 512
  description = "memory for the ECS container"
}

variable "container_port" {
  type        = number
  default     = 80
  description = "value for the container port"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "desired_count" {
  type        = number
  default     = 1
  description = "desired count for the ECS service"
}

variable "enable_exec" {
  type        = bool
  default     = false
  description = "enable command execution for the ECS service"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID for the ECS service"
}
variable "alb_security_groups" {
  type        = list(string)
  description = "ALB security groups for the ECS service"
}
variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "assign public ip for the ECS service"
}

variable "alb_target_group" {
  type        = string
  description = "target group for the ECS service"
}

variable "private_subnets" { type = list(string) }

variable "environment_vars" {
  default = {}
  type = map(string)
}

variable "secrets" {
  description = "Secrets from AWS Secrets Manager"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "db_credentials_arn" {
  description = "ARN of db secrets"
  default = ""
  type = string
}