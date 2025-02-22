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
  name               = "lambda_role_${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy_${var.function_name}"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda_container_based" {
  count          = var.container_based ? 1 : 0
  image_uri      = "${var.repository_url}:latest"
  function_name  = var.function_name
  package_type   = "Image"
  role           = aws_iam_role.iam_for_lambda.arn
}

data "archive_file" "lambda_zip" {
  count       = var.container_based ? 0 : 1
  type        = "zip"
  source_file = var.source_file
  output_path = "lambda_source.zip"
}

resource "aws_lambda_function" "lambda_standard" {
  count            = var.container_based ? 0 : 1
  function_name    = var.function_name
  runtime          = "python3.10"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = data.archive_file.lambda_zip[0].output_path
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256
}