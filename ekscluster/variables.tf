variable "account_id" {
  description = "AWS account ID"
  nullable    = false
}

output "account_id" {
  value = var.account_id
}

variable "region" {
  description = "value of the AWS region to deploy to"
  nullable    = false
}

output "region" {
  value = var.region
}

variable "cluster_oidc_issuer_url" {
  description = "The OIDC Identity issuer URL for the cluster"
  type        = string
  nullable    = false
}

variable "role_arn" {
  description = "Aws role arn"
}

variable "s3_bucket" {
  description = "value of the AWS s3 bucket"
}

variable "s3_policy" {
  description = "value of the AWS s3 policy"
}

variable "cluster_name" {}

