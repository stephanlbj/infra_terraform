provider "aws" {
  region = var.aws_region
}

# Récupérer l’account_id pour rendre le bucket unique
data "aws_caller_identity" "current" {}

# Bucket S3 (unique par compte AWS)
resource "aws_s3_bucket" "nextjs_staging" {
  bucket = "${var.s3_bucket}-${data.aws_caller_identity.current.account_id}"
}

# Ownership (remplace l’ancien acl)
resource "aws_s3_bucket_ownership_controls" "staging" {
  bucket = aws_s3_bucket.nextjs_staging.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
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

# Politique publique pour S3
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.nextjs_staging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.nextjs_staging.arn}/*"
      }
    ]
  })
}

# Distribution CloudFront
resource "aws_cloudfront_distribution" "staging_cdn" {
  origin {
    domain_name = aws_s3_bucket.nextjs_staging.bucket_regional_domain_name
    origin_id   = "S3-nextjs-staging"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-nextjs-staging"
    viewer_protocol_policy = "redirect-to-https"
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
