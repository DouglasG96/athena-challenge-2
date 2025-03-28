variable "project_name" {
  type    = string
  default = "athena"
}
variable "container_image" { type = string }
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
variable "security_groups" {
  type        = list(string)
  description = "security groups for the ECS service"
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