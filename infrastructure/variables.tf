variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project, used for tagging resources."
  type        = string
  default     = "internal-dashboard"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "The CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "The CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "domain_name" {
  description = "The domain name for the application. This must be a registered domain in Route 53."
  type        = string
  # A default is provided for demonstration, but this should be overridden.
  default = "example.com"
}

variable "cognito_user_username" {
  description = "The username for the initial Cognito user."
  type        = string
  default     = "admin"
}

variable "cognito_user_password" {
  description = "The password for the initial Cognito user. Must be at least 8 characters with upper, lower, numbers, and symbols."
  type        = string
  sensitive   = true
  # No default is provided for security reasons.
  # The user will be prompted to enter this when running `terraform apply`.
}
