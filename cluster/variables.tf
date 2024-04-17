variable "cluster" {
  type = object({
    name             = string
    deployment_id    = string
    kube_state_image = string
    otel_image       = string
  })
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC Identity issuer URL for the cluster"
  nullable    = false
}

variable "ec2_cluster" {
  type        = bool
  description = "Set to true if this is a self-managed cluster running on EC2"
  default     = false
}
