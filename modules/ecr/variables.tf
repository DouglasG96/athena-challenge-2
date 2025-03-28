variable "project_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "If true, the repository will be deleted even if it contains images"
  type        = bool
  default     = false
}