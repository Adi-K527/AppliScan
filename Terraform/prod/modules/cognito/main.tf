resource "aws_cognito_user_pool" "appliscan_user_pool" {
  name = var.cognito_name
}

resource "aws_cognito_user_pool_client" "appliscan_app_client" {
  name          = "${var.cognito_name} Client"
  user_pool_id  = aws_cognito_user_pool.appliscan_user_pool.id
  callback_urls = [ var.cognito_redirect_url ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]

  depends_on    = [ aws_cognito_user_pool.appliscan_user_pool ]
}

resource "aws_cognito_user_pool_domain" "cognito_domain" {
  domain = "appliscan-${var.unique_domain}"
  user_pool_id = aws_cognito_user_pool.appliscan_user_pool.id
}

resource "aws_cognito_user_pool_ui_customization" "cognito_ui" {
  user_pool_id = aws_cognito_user_pool.appliscan_user_pool.id
  client_id    = aws_cognito_user_pool_client.appliscan_app_client.id
  css          = file("${var.css_file_path}")
}