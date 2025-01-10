variable "permissions_boundary" {
  type        = string
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  default     = ""
}

variable "s3_tags" {
  type = map(string)
  description = "Tags to apply to the S3 bucket"
  default = {}
}
