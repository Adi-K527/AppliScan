output "cognito_signin_url" {
  value = aws_cognito_user_pool.appliscan_cognito_user_pool.domain
}