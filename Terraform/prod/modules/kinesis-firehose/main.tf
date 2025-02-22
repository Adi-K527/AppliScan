resource "aws_s3_bucket" "firehose_delivery_bucket" {
  bucket = var.s3_bucket_name
}

module "lambda_transformer" {
  source          = "../lambda"
  function_name   = "firehose-transformer"
  source_file    = var.lambda_source_file
  container_based = false
}

# IAM Role for firehose to assume and gain permissions to put objects to S3
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "firehose_s3_policy" {
  name        = "firehose_s3_policy"
  description = "Allow Firehose to write to S3"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action   = ["s3:PutObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.firehose_delivery_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_s3" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_s3_policy.arn
}
#########################################################################


resource "aws_kinesis_firehose_delivery_stream" "email_stream_processor" {
  name        = var.firehose_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.firehose_delivery_bucket.arn

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