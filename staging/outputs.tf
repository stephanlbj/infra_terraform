output "s3_bucket" {
  value = aws_s3_bucket.nextjs_staging.id
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.staging_cdn.domain_name
}