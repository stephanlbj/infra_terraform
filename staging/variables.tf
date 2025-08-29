variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "s3_bucket" {
  description = "Nom de base du bucket S3 pour staging"
  default     = "mon-bucket-staging"
  type        = string
}
