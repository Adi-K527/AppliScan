resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy" "glue_policy" {
  role = aws_iam_role.glue_service_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_s3_object" "glue_script" {
  bucket = var.s3_bucket_name
  key    = "scripts/etl.py"
  source = var.code_path   
  etag   = filemd5(var.code_path)
}

resource "aws_glue_job" "python_shell_job" {
  name              = "python-shell-job"
  role_arn          = aws_iam_role.glue_service_role.arn
  glue_version      = "1.0"
  command {
    script_location = "s3://${var.s3_bucket_name}/scripts/etl.py"
    python_version  = "3.9"
    name            = "pythonshell"
  }

  timeout     = 10
}

resource "aws_glue_trigger" "every_30_mins" {
  name     = "every-30-mins-trigger"
  type     = "SCHEDULED"
  schedule = "cron(0/30 * * * ? *)" # Every 30 minutes

  actions {
    job_name = aws_glue_job.python_shell_job.name
  }

  start_on_creation = true
}

