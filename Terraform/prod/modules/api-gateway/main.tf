resource "aws_api_gateway_resource" "model_resource" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "model_method" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.model_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "model_integration" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.model_resource.id
  http_method             = aws_api_gateway_method.model_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = var.api_id
  depends_on  = [ aws_api_gateway_integration.model_integration]   
}

resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  rest_api_id   = var.api_id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

resource "aws_lambda_permission" "api_gateway_permission_ner_model" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/*"
}