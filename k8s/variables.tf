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

variable "cluster" {
  type = object({
    cluster_name     = string
    deployment_id    = string
    kube_state_image = string
    otel_image       = string
  })
}

variable "role_arn" {
  description = "Aws role arn"
  nullable    = true
}

output "role_arn" {
  value = var.role_arn
}

variable "s3_bucket" {
  description = "value of the AWS s3 bucket"
  nullable    = true
}

output "s3_bucket" {
  value = var.s3_bucket
}

variable "aws_access_key" {
  description = "value of the AWS access key is used to ec2 clusters"
  nullable    = true
  default     = ""
}

output "aws_access_key" {
  value = var.aws_access_key
}

variable "aws_secret_key" {
  description = "value of the AWS secret key is used to ec2 clusters"
  nullable    = true
  default     = ""
}

output "aws_secret_key" {
  value = var.aws_secret_key
}

variable "ec2_cluster" {
  type        = bool
  description = "if true then deploy to ec2 cluster"
  default     = false
}

output "ec2_cluster" {
  value = var.ec2_cluster
}
