# terraform-eks-lens-cluster

This module creates the S3 bucket used by EKS Lens to store artifacts, it also creates the IAM resources for DoiT to have access to the bucket.
It needs to be created only _once_ per AWS account _and_ region.

## Usage

```hcl
module "<REGION_NAME>-base" {
  source = "git::https://github.com/doitintl/terraform-eks-lens.git//region-base"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|  |  |  |  |  |

## Outputs

| Name | Description |
|------|-------------|
| account\_id | The ID of the used AWS account |
| region | AWS region used |
| bucket\_name | The name of the EKS Lens S3 bucket |
| s3\_policy\_arn | ARN of the S3 IAM policy to access the EKS Lens bucket |
| role\_arn | ARN of the IAM role to access the EKS Lens bucket |
