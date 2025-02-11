resource "aws_s3_bucket" "appliscan_frontend" {
  bucket = "appliscan-frontend"
}

resource "aws_s3_bucket_public_access_block" "appliscan_frontend_unblock" {
  bucket = aws_s3_bucket.appliscan_frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "appliscan_frontend_public_access_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.appliscan_frontend.arn}/*"]

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "appliscan_frontend_public_access" {
  bucket = aws_s3_bucket.appliscan_frontend.id
  policy = data.aws_iam_policy_document.appliscan_frontend_public_access_document.json
}

resource "aws_s3_bucket_website_configuration" "appliscan_frontend_static_hosting" {
  bucket = aws_s3_bucket.appliscan_frontend.id

  index_document {
    suffix = "index.html"
  }
}






resource "aws_ecr_repository" "appliscan_ecr" {
  name = var.ecr_name
}

resource "null_resource" "docker_operations" {
  provisioner "local-exec" {
    command = <<-EOT
      docker pull alpine
      docker tag alpine ${aws_ecr_repository.appliscan_ecr.repository_url}:latest
      docker push ${aws_ecr_repository.appliscan_ecr.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.appliscan_ecr]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "appliscan-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "appliscan-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "JobStatusModel" {
  image_uri      = "${aws_ecr_repository.appliscan_ecr.repository_url}:latest"
  function_name  = "JobStatusModel"
  package_type   = "Image"
  role           = aws_iam_role.iam_for_lambda.arn
  depends_on     = [null_resource.docker_operations]
}

resource "aws_lambda_function" "NerModel" {
  image_uri      = "${aws_ecr_repository.appliscan_ecr.repository_url}:latest"
  function_name  = "NerModel"
  package_type   = "Image"
  role           = aws_iam_role.iam_for_lambda.arn
  depends_on     = [null_resource.docker_operations]
}

resource "aws_api_gateway_rest_api" "appliscan_api" {
  name         = "Appliscan"
  description  = "Appliscan api to interact with models."
}

resource "aws_api_gateway_resource" "job_status_model_api" {
  rest_api_id = aws_api_gateway_rest_api.appliscan_api.id
  parent_id   = aws_api_gateway_rest_api.appliscan_api.root_resource_id
  path_part   = "JobStatusModel"
}

resource "aws_api_gateway_resource" "ner_model_api" {
  rest_api_id = aws_api_gateway_rest_api.appliscan_api.id
  parent_id   = aws_api_gateway_rest_api.appliscan_api.root_resource_id
  path_part   = "NerModel"
}

resource "aws_api_gateway_method" "job_status_model_method" {
  rest_api_id   = aws_api_gateway_rest_api.appliscan_api.id
  resource_id   = aws_api_gateway_resource.job_status_model_api.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ner_model_method" {
  rest_api_id   = aws_api_gateway_rest_api.appliscan_api.id
  resource_id   = aws_api_gateway_resource.ner_model_api.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "job_status_model_integration" {
  rest_api_id             = aws_api_gateway_rest_api.appliscan_api.id
  resource_id             = aws_api_gateway_resource.job_status_model_api.id
  http_method             = aws_api_gateway_method.job_status_model_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.JobStatusModel.invoke_arn
}

resource "aws_api_gateway_integration" "ner_model_integration" {
  rest_api_id             = aws_api_gateway_rest_api.appliscan_api.id
  resource_id             = aws_api_gateway_resource.ner_model_api.id
  http_method             = aws_api_gateway_method.ner_model_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.NerModel.invoke_arn
}

resource "aws_api_gateway_deployment" "appliscan_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.appliscan_api.id
  stage_name  = "prod"
  depends_on  = [ aws_api_gateway_integration.job_status_model_integration, 
                  aws_api_gateway_integration.ner_model_integration ]   
}

resource "aws_lambda_permission" "api_gateway_permission_job_status_model" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.JobStatusModel.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.appliscan_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_permission_ner_model" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.NerModel.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.appliscan_api.execution_arn}/*/*"
}