resource "aws_cognito_user_pool" "appliscan_user_pool" {
  name = var.cognito_name
}

resource "aws_cognito_user_pool_client" "appliscan_app_client" {
  name          = "${var.cognito_name} Client"
  user_pool_id  = aws_cognito_user_pool.appliscan_user_pool.id
  callback_urls = [ var.cognito_redirect_url ]

  allowed_oauth_flows                  = [ "code" ]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true

  explicit_auth_flows = [ 
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]

  depends_on    = [ aws_cognito_user_pool.appliscan_user_pool ]
}

resource "aws_cognito_user_pool_domain" "cognito_domain" {
  domain = "appliscan-${var.unique_domain}"
  user_pool_id = aws_cognito_user_pool.appliscan_user_pool.id
}

resource "aws_cognito_user_pool_ui_customization" "cognito_ui" {
  user_pool_id = aws_cognito_user_pool.appliscan_user_pool.id
  client_id    = aws_cognito_user_pool_client.appliscan_app_client.id
  css          = ".label-customizable {font-weight: 400;}"
}

resource "aws_cognito_identity_provider" "cognito_identity_provider" {
  user_pool_id      = aws_cognito_user_pool.appliscan_user_pool.id
  provider_name     = "COGNITO"
  provider_type     = "COGNITO"
  provider_details = {
    authorize_scopes = "email"
    client_id        = aws_cognito_user_pool_client.appliscan_app_client.id
    client_secret    = aws_cognito_user_pool_client.appliscan_app_client.client_secret
  }
}