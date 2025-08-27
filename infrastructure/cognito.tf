# ------------------------------------------------------------------------------
# Cognito for Authentication
# ------------------------------------------------------------------------------

# Random string to ensure the Cognito domain is unique
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  tags = {
    Name = "${var.project_name}-user-pool"
  }
}

# Cognito User Pool Client for the ALB
resource "aws_cognito_user_pool_client" "main" {
  name                                 = "${var.project_name}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.main.id
  generate_secret                      = false # Not needed for ALB integration
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]
  callback_urls                        = ["https://${var.domain_name}/oauth2/idpresponse"]
  logout_urls                          = ["https://${var.domain_name}"]
  supported_identity_providers         = ["COGNITO"]
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-auth-${random_string.suffix.result}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Initial user for access
resource "aws_cognito_user" "admin" {
  user_pool_id = aws_cognito_user_pool.main.id
  username     = var.cognito_user_username
}

# Set the initial user's password using a provisioner and the AWS CLI
# This is a standard workaround for setting a permanent password in Terraform.
resource "null_resource" "set_user_password" {
  # This triggers whenever the user is created or the password variable changes.
  triggers = {
    user_pool_id = aws_cognito_user_pool.main.id
    username     = aws_cognito_user.admin.username
    password     = var.cognito_user_password
  }

  provisioner "local-exec" {
    # Note: The environment executing this Terraform must have the AWS CLI installed
    # and configured with permissions for cognito-idp:AdminSetUserPassword.
    command = <<EOT
      aws cognito-admin-set-user-password \
        --user-pool-id ${self.triggers.user_pool_id} \
        --username "${self.triggers.username}" \
        --password "${self.triggers.password}" \
        --permanent
    EOT
  }

  depends_on = [aws_cognito_user.admin]
}
