output "api_gateway_id" {
  value = aws_api_gateway_rest_api.appliscan_api.id
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}