output "workspace" {
  value = terraform.workspace
}

output "bucket_id" {
  value = aws_s3_bucket.firehose_delivery_bucket.id
}