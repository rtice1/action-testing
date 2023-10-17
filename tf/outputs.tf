output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.evolve_bucket.id
}

output "s3_bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the S3 bucket"
  value       = aws_s3_bucket.evolve_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "The DNS domain name of the S3 bucket"
  value       = aws_s3_bucket.evolve_bucket.bucket_domain_name
}

output "s3_bucket_policy" {
  description = "The JSON content of the S3 bucket policy"
  value       = aws_s3_bucket_policy.evolve_bucket_policy[0].policy
}

output "kms_key_id" {
  description = "The ID of the KMS key used for server-side encryption"
  value       = aws_kms_key.evolve_key[0].id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for server-side encryption"
  value       = aws_kms_key.evolve_key[0].arn
}
