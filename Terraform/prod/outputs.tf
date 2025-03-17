output "workspace" {
  value = terraform.workspace
}

output "cognito_signin_url" {
  value = aws_cognito_user_pool.appliscan_cognito_user_pool.domain
}