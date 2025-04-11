variable "s3_bucket_name" {
  description = "S3 bucket name for Glue job"
  type        = string
}

variable "code_path" {
  description = "Glue job code path"
  type        = string
}