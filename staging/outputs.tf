output "cloudfront_distribution_id" {
  description = "ID de la distribution CloudFront"
  value       = aws_cloudfront_distribution.staging_cdn.id
}

output "cloudfront_domain_name" {
  description = "Nom de domaine de la distribution CloudFront"
  value       = aws_cloudfront_distribution.staging_cdn.domain_name
}

output "s3_bucket_name" {
  description = "Nom du bucket S3 staging"
  value       = aws_s3_bucket.nextjs_staging.bucket
}

output "cloudfront_oac_id" {
  description = "ID de l'Origin Access Control utilisé par CloudFront pour accéder au bucket S3"
  value       = aws_cloudfront_origin_access_control.staging_oac.id
}
