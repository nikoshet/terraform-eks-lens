variable "region" {
  description = "value of the AWS region to deploy to"
  nullable    = false
}

output "region" {
  value = var.region
}
