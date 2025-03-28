variable "project_name" {
  type = string
}
variable "alb_port" {
  type = number
}

variable "load_balancer_type" {
  type    = string
  default = "application"
}
variable "security_groups" {
  default     = []
  description = "Security groups to attach to the ALB"
}
variable "internal_alb" {
  type    = bool
  default = false
}

variable "access_logs" { type = list(any) }
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "scope" { type = string }