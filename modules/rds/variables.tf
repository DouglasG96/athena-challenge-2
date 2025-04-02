variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}


variable "db_username" {
  description = "Master username for database"
  type        = string
}

variable "db_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}

variable "cluster_instances" {
  description = "Number of Aurora instances to create"
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.t3.medium"
}

variable "ecs_security_group_id" {
  description = "Security group ID of ECS service that needs DB access"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when destroying DB"
  type        = bool
  default     = false
}