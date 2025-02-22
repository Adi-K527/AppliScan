resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_unblock" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "s3_public_access_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
    effect    = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_public_access" {
  bucket     = aws_s3_bucket.s3_bucket.id
  policy     = data.aws_iam_policy_document.s3_public_access_document.json
  depends_on = [ aws_s3_bucket_public_access_block.s3_bucket_unblock ]
}

resource "aws_s3_bucket_website_configuration" "s3_static_hosting" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_distribution" "cloudfront_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.s3_static_hosting.website_endpoint
    origin_id   = aws_s3_bucket.s3_bucket.bucket
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    cache_policy_id         = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods          = ["GET", "HEAD"]
    allowed_methods         = ["GET", "HEAD"]
    target_origin_id        = aws_s3_bucket.s3_bucket.bucket
    viewer_protocol_policy  = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  depends_on      = [ aws_s3_bucket_policy.s3_public_access ] 
}
