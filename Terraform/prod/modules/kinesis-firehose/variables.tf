variable "s3_bucket_name" {
  description = "Name of origin S3 bucket"
  type = string
}

variable "firehose_name" {
  description = "Name of Kinesis Firehose resource"
  type = string
}