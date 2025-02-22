output "lambda_arn" {
    value = var.container_based ? aws_lambda_function.lambda_container_based.invoke_arn : aws_lambda_function.lambda_standard.invoke_arn
}