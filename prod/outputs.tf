output "s3_bucket" {
  value = aws_s3_bucket.nextjs_prod.id
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.prod_cdn.domain_name
}
