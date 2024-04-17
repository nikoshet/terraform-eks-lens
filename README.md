# terraform-eks-lens

Terraform modules to deploy DoiT's EKS Lens feature to AWS.

## Requirements

### Installation Dependencies

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws) v5.3+
- [terraform-provider-kubernetes](https://github.com/terraform-providers/terraform-provider-kubernetes) plugin v2.2+

## Modules

- [region-base](https://github.com/doitintl/terraform-eks-lens/blob/main/region-base/) - creates the base resources required for running EKS Lens in an account and region.
- [cluster](https://github.com/doitintl/terraform-eks-lens/blob/main/cluster/) - creates the resources required for EKS Lens in a given Kubernetes cluster and optionally deploys it to that cluster.

## Provider configuration

See some configuration example in [providers_example.tf](https://github.com/doitintl/terraform-eks-lens/blob/main/provider.tf.example).

### AWS Provider

If not already in use, the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) will need to be configured by adding a `provider` block.

### Kubernetes Provider

If not already in use, the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) will need to be configured by adding a `provider` block.

## Usage

Download your accounts Terraform configuration from the EKS Lens console and place it alongside your provider configuration.

Then run the following commands:
```bash
terraform init
terraform plan
terraform apply
```

The configuration file should contain the following module definitions:

### Once per account and region

The `region-base` module needs to be created _once_ per account and region.

```hcl
module "<REGION_NAME>-base" {
  source = "git::https://github.com/doitintl/terraform-eks-lens.git//region-base"
}
```

The region and account ID are [inferred](https://github.com/doitintl/terraform-eks-lens/blob/main/region-base/main.tf#L5-L6) from your AWS provider configuration.
Make sure that your AWS provider is configured to use the correct account and region.

### Per cluster

The `cluster` module needs to be created once _per cluster_.

```hcl
module "<REGION>-<CLUSTER_NAME>" {
  source = "git::https://github.com/doitintl/terraform-eks-lens.git//cluster"

  cluster = {
    cluster_name     = "<CLUSTER_NAME>"
    deployment_id    = "<DEPLOYMENT_ID>"
    kube_state_image = "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2" # make sure to use the latest available image
    otel_image       = "otel/opentelemetry-collector-contrib:0.83.0" # make sure to use the latest available image
  }
  # If running in EKS:
  cluster_oidc_issuer_url = "<CLUSTER_OIDC_ISSUER_URL>"
  # Alternatively, if managing your own cluster on EC2, set `cluster_oidc_issuer_url` to an empty string and uncomment the following:
  #ec2_cluster = true

  # By default, this module will also deploy the k8s manifests. Set to `false` if planning to deploy with another tool
  #deploy_manifests = false

  # when configuring multiple providers for different clusters, you can configure the module to use to correct provider alias:
  providers = {
    kubernetes = kubernetes.<PROVIDER_ALIAS>
  }
}
```

## DoiT webhooks for on/off-boarding

The `cluster` module contains a `null_resource` that should run a webhook on creation and destruction of a given cluster module.

The on-boarding hook validates your cluster deployment and registers it. If it fails on creation, you might need to try applying again for it to register successfully.

The off-boarding hook de-registers your cluster deployment. In case it fails you might need to manually call the webhook:

```bash
curl -X POST -H 'Content-Type: application/json' -d '{"account_id": "<<AccountID>>","region": "<<Region>>","cluster_name": "<<ClusterName>>", "deployment_id": "<<DeploymentID>>" }' https://console.doit.com/webhooks/v1/eks-metrics/terraform-destroy
```
