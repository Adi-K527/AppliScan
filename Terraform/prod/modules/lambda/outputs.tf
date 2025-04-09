output "lambda_arn" {
    value = var.container_based ? aws_lambda_function.lambda_container_based[0].arn : aws_lambda_function.lambda_standard[0].arn
}

output "lambda_invoke_arn" {
    value = var.container_based ? aws_lambda_function.lambda_container_based[0].invoke_arn : aws_lambda_function.lambda_standard[0].invoke_arn
}