output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.staging_cdn.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.staging_cdn.domain_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.nextjs_staging.bucket
}
