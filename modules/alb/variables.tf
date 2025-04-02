variable "project_name" {
  type = string
}
variable "alb_port" {
  type = number
}
variable "container_port" {
  type = number
}

variable "load_balancer_type" {
  type    = string
  default = "application"
}
variable "internal_alb" {
  type    = bool
  default = false
}

# variable "access_logs" { type = list(any) }
variable "vpc_id" {
  type    = string
  default = ""
}
variable "public_subnets" { type = list(string) }
variable "scope" { type = string }