variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "waf_name" { type = string }
variable "scope" { type = string }