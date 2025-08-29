variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "s3_bucket" {
  description = "Nom du bucket S3 pour staging"
  default     = "mon-bucket-staging"
  type        = string
  
}

variable "cloudfront_distribution_id" {
  description = "ID de la distribution CloudFront pour staging"
  default     = "XXXXXXXXXXXX"
  type        = string
}