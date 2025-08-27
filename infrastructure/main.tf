terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  # Note: In a real-world scenario, you would use a remote backend like S3
  # to store the Terraform state file. For this challenge, we use the default local backend.
}

provider "aws" {
  region = var.aws_region
}
