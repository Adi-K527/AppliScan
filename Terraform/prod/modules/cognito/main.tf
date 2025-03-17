resource "aws_cognito_user_pool" "appliscan_user_pool" {
  name                     = var.cognito_name
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "appliscan_app_client" {
  name          = "${var.cognito_name} Client"
  user_pool_id  = aws_cognito_user_pool.appliscan_user_pool.id
  callback_urls = [ var.cognito_redirect_url ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  depends_on    = [ aws_cognito_user_pool.appliscan_user_pool ]
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_cognito_user_pool_domain" "appliscan_domain" {
  domain       = "appliscan-9138y479" 
  user_pool_id = aws_cognito_user_pool.appliscan_user_pool.id
}