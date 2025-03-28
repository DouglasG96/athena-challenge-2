terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "athena-terraform-state"
    key    = "athena/prod-terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Environment = var.environment
      Owner       = "drgb96@gmail.com"
      Project     = "Athena-Challenge-2"
      created_by  = "terraform"
      repo        = "github.com/DouglasG96/athena-challenge-2"
    }
  }
}
