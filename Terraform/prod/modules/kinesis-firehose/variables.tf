variable "bucket_id" {
  description = "ID of S3 bucket"
  type        = string
}

variable "firehose_name" {
  description = "Name of Kinesis Firehose resource"
  type        = string
}

variable "lambda_source_file" {
  description = "Source file for lambda transformer"
  type        = string
}

variable "job_related_model_function_arn" {
  description = "ARN for job related model lambda function"
  type        = string
}