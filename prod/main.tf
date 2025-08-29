provider "aws" {
  region = var.aws_region
}

# Bucket S3
resource "aws_s3_bucket" "nextjs_prod" {
  bucket = var.s3_bucket
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# Politique publique pour S3
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.nextjs_prod.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.nextjs_prod.arn}/*"
      }
    ]
  })
}

# Distribution CloudFront
resource "aws_cloudfront_distribution" "prod_cdn" {
  origin {
    domain_name = aws_s3_bucket.nextjs_prod.bucket_regional_domain_name
    origin_id   = "S3-nextjs-prod"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-nextjs-prod"
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
