variable "s3_bucket_name" {
  description = "Name of origin S3 bucket"
  type = string
}

variable "firehose_name" {
  description = "Name of Kinesis Firehose resource"
  type = string
}

variable "lambda_source_file" {
  description = "Source file for lambda transformer"
  type = string
}