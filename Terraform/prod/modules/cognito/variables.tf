variable "cognito_name" {
  description = "Name of origin S3 bucket"
  type        = string
}

variable "cognito_redirect_url" {
  description = "Cognito redirect URL"
  type        = string
}

variable "unique_domain" {
  description = "Unique domain to add to url"
  type        = string
}

variable "css_file_path" {
  description = "Path to css file for cognito ui"
  type = string
}