# Terraform module to deploy Doit EKS Lens feature to AWS

* [On boarding](#On-boarding)
* [Off boarding](#Off-boarding)

## On boarding

Clone this repository for each account/region:
```bash
git clone https://github.com/doitintl/terraform-eks-lens.git eks-lens-{account}-{region}

cd eks-lens-{account}-{region}
```
Download Your cluster's specific terraform file ({clustername}.tf) from the EKS Lens console and place it in.

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
```bash
export AWS_ACCESS_KEY_ID="<<aws-access_key>>"
export AWS_SECRET_ACCESS_KEY="<<aws-secret_key>>"
export AWS_REGION="<<aws-region>>"
```

OR

```hcl
provider "aws" {
  shared_config_files      = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  profile                  = "customprofile"
}
```

Then run the following commands:
```bash
terraform init
terraform plan
terraform apply
```

## Off boarding

Delete cluster's specific terraform file ({clustername}.tf)

execute the following command:
```bash
curl -X POST -H 'Content-Type: application/json' -d '{"account_id": "<<AccountID>>","region": "<<Region>>","cluster_name": "<<ClusterName>>", "deployment_id": "<<DeploymentID>>" }' https://console.doit.com/webhooks/v1/eks-metrics/terraform-destroy
```
