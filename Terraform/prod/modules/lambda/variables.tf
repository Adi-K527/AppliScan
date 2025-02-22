variable "repository_url" {
  description  = "ECR repository for Lambda"
  type         = string
  default      = ""
}

variable "function_name" {
  description  = "Lambda function name"
  type         = string
}

variable "container_based" {
  description  = "Boolean if lambda function is container based"
  type         = bool
  default      = true
}

variable "source_file" {
  description  = "Lambda function source file"
  type         = string
  default      = "test"
}