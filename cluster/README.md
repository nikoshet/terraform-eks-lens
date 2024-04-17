# terraform-eks-lens-cluster

This module creates the necessary IAM permissions for your EKS Lens workload to access the S3 bucket and push data into it.
It also optionally deploys EKS Lens into the cluster and will onboard it to DoiT after creation. If deployments is enabled, it'll also offboard the cluster upon destruction.

## Usage

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster | An object containing cluster configuration | <pre>object({<br>    name             = string<br>    deployment_id    = string<br>    kube_state_image = string<br>    otel_image       = string<br>  })</pre>| n/a | yes |
| doit\_webhook\_url | The base URL used for calling the DoiT webhook and registering/de-registering the cluster from EKS Lens | `string` | `"https://console.doit.com/webhooks/v1/eks-metrics"` | no |
| cluster\_oidc\_issuer\_url | The OIDC Identity issuer URL for the EKS cluster | `string` | n/a | yes |
| ec2\_cluster | Set to true if this is a self-managed k8s cluster running on EC2 (if so, you could also set `cluster_oidc_issuer_url` to an empty string) | `bool` | `false` | no |
| deploy\_manifests | Set to false if you don't want this module to deploy EKS Lens into your cluster | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| account\_id | The ID of the used AWS account |
| region | AWS region used |
| deployment\_id | Deployment ID as provided by DoiT |
| collector\_deployment | The Open Telemetry deployment name in the format of `namespace/name` |
| kube\_state\_metrics\_deployment | The `kube-state-metrics` deployment name in the format of `namespace/name` |
