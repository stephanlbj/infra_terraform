provider "aws" {
  region = var.aws_region
}

# Récupérer l’account_id pour rendre le bucket unique
data "aws_caller_identity" "current" {}

# Bucket S3 (unique par compte AWS + timestamp)
resource "aws_s3_bucket" "nextjs_staging" {
  bucket = "${var.s3_bucket}-${data.aws_caller_identity.current.account_id}-${timestamp()}"
}

# Ownership
resource "aws_s3_bucket_ownership_controls" "staging" {
  bucket = aws_s3_bucket.nextjs_staging.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Bloquer l'accès public direct
resource "aws_s3_bucket_public_access_block" "staging" {
  bucket                  = aws_s3_bucket.nextjs_staging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuration site web pour S3
resource "aws_s3_bucket_website_configuration" "staging" {
  bucket = aws_s3_bucket.nextjs_staging.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Origin Access Control (OAC) pour CloudFront
resource "aws_cloudfront_origin_access_control" "staging_oac" {
  name                              = "staging-oac"
  description                       = "OAC for staging bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Policy pour autoriser CloudFront à lire depuis S3
resource "aws_s3_bucket_policy" "staging_policy" {
  bucket = aws_s3_bucket.nextjs_staging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.nextjs_staging.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.staging_cdn.arn
          }
        }
      }
    ]
  })
}

# Distribution CloudFront
resource "aws_cloudfront_distribution" "staging_cdn" {
  origin {
    domain_name              = aws_s3_bucket.nextjs_staging.bucket_regional_domain_name
    origin_id                = "S3-nextjs-staging"
    origin_access_control_id = aws_cloudfront_origin_access_control.staging_oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-nextjs-staging"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
