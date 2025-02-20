variable "path" {
  description  = "Path for new route in api gateway"
  type         = string
}

variable "lambda_function_name" {
  description  = "Associated Lambda function name"
  type         = string
}

variable "lambda_invoke_arn" {
  description  = "Invoke ARN for associated Lambda function"
  type         = string
}
