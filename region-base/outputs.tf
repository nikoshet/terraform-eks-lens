output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region
}

output "bucket_name" {
  value       = aws_s3_bucket.doit_eks_lens.id
  description = "S3 bucket containing EKS Lens artifacts"
}

output "s3_policy_arn" {
  value       = aws_iam_policy.doit_eks_lens.arn
  description = "IAM policy ARN to access EKS Lens S3 bucket"
}

output "role_arn" {
  value       = aws_iam_role.doit_eks_lens_import.arn
  description = "IAM role ARN to access EKS Lens S3 bucket"
}
