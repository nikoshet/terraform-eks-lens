# Terraform module to deploy Doit EKS Lens feature to AWS

!!! warning
    This module is in development and should not be used in production.


Clone this repository for each account/region:
```bash
git clone https://github.com/doitintl/terraform-eks-lens.git eks-lens-{account}-{region}

cd eks-lens-{account}-{region}
```
Download Your cluster's specific terraform file ({clustername}.tf) from the EKS Lens console and place it in.

If you have EC2 cluster (not eks) in this account/region then you should create a aws_iam_user
Open the aws_iam_user.tf file and enable it.

Configure your cluster provider in the {clustername}_provider.tf file.
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
```hcl
## Configure Your Cluster Provider
# With .kube/config
provider "kubernetes" {
  alias          = "<<clustername>>"
  config_path    = "~/.kube/config"
  config_context = "<<Your Cluster Context>>"
}

# OR with Certificates
provider "kubernetes" {
  alias                  = "<<clustername>>"
  host                   = "https://<<Your Cluster Host>>"
  client_certificate     = file("<<cert.pem>>")
  client_key             = file("<<key.pem>>")
  cluster_ca_certificate = file("<<ca-cert.pem>>")
}

# OR with AWS 
provider "kubernetes" {
  alias                  = "<<clustername>>"
  host                   = data.aws_eks_cluster.<<Your Cluster>>.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.<<Your Cluster>>.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.<<Your Cluster>>.token
}

```

Set up your AWS provider in the aws_provider.tf file:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs
```hcl
provider "aws" {
  access_key = "<<aws-access_key>>"
  secret_key = "<<aws-secret_key>>"
  region     = "<<aws-region>>"
}
```
OPTIONAL: Set up your AWS provider using environment variables:
```bash
export AWS_ACCESS_KEY_ID="<<aws-access_key>>"
export AWS_SECRET_ACCESS_KEY="<<aws-secret_key>>"
export AWS_REGION="<<aws-region>>"
```