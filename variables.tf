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

variable "cluster_name" {
  description = "EKS cluster name to deploy to"
  nullable    = false
}

output "cluster_name" {
  value = var.cluster_name
}

variable "cluster_oidc_issuer_url" {
  description = "The OIDC Identity issuer URL for the cluster"
  type        = string
  nullable    = false
}

variable "deployment_id" {
  description = "Desired Deployment ID"
  type        = string
  nullable    = false
}

output "deployment_id" {
  value = var.deployment_id
}

variable "kube_state_image" {
  description = "The kube-state-metrics image to deploy"
  type        = string
  nullable    = false
}

variable "otel_image" {
  description = "The OpenTelemetry Collector image to deploy"
  type        = string
  nullable    = false
}


variable "ec2_cluster" {
  type        = bool
  description = "if true then deploy to ec2 cluster"
  default     = false
}

