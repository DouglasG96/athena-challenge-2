variable "aws_region" {
  description = "The AWS region to deploy the resources"
  default     = "us-east-1"
  type        = string
}
variable "aws_profile" {
  description = "The AWS profile to use"
  default     = "default"
  type        = string
}

variable "state_s3_bucket" {
  description = "The name of the S3 bucket to store the Terraform state file"
  default     = "athena-ch2-terraform-state"
  type        = string
}

variable "prevent_destroy" {
  description = "Prevent accidental deletion of the S3 bucket"
  default     = true
  type        = bool
}

variable "versioning_configuration" {
  description = "Enable versioning for the S3 bucket"
  default     = "Enabled"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to store the Terraform state lock"
  default     = "athena-terraform-locks"
  type        = string
}