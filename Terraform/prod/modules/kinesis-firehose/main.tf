resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_arn

  lambda_function {
    lambda_function_arn = var.job_related_model_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }
}

module "lambda_transformer" {
  source          = "../lambda"
  function_name   = "firehose-transformer"
  source_file     = var.lambda_source_file
  container_based = false
}

# IAM Role for firehose to assume and gain permissions to put objects to S3
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version     = "2012-10-17"
    Statement   = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "firehose_policy" {
  name        = "firehose_policy"
  description = "Allow Firehose to write to S3 and invoke Lambda"

  policy = jsonencode({
    Version    = "2012-10-17"
    Statement  = [{
      Action   = ["s3:PutObject"]
      Effect   = "Allow"
      Resource = "${var.bucket_arn}/*"
    },
    {
      Action   = ["lambda:InvokeFunction"]
      Effect   = "Allow"
      Resource = module.lambda_transformer.lambda_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}
#########################################################################


resource "aws_kinesis_firehose_delivery_stream" "email_stream_processor" {
  name        = var.firehose_name
  destination = "extended_s3"
  depends_on  = [ module.lambda_transformer ]

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.bucket_arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = module.lambda_transformer.lambda_arn
        }
      }
    }
  }
}

