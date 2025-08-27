# Outputs will be added here as resources are created in subsequent steps.

output "ecr_repo_backend_url" {
  description = "The URL of the backend ECR repository."
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_repo_frontend_url" {
  description = "The URL of the frontend ECR repository."
  value       = aws_ecr_repository.frontend.repository_url
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.main.id
}

output "cloudwatch_alarm_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}
