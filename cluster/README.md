# terraform-eks-lens-cluster

This module creates the necessary IAM permissions for your EKS Lens workload to access the S3 bucket and push data into it.
It also optionally deploys EKS Lens into the cluster and will onboard it to DoiT after creation. If deployments is enabled, it'll also offboard the cluster upon destruction.

## Usage

```hcl
module "<REGION>-<CLUSTER_NAME>" {
  source = "git::https://github.com/doitintl/terraform-eks-lens.git//cluster"

  cluster = {
    name             = "<CLUSTER_NAME>"
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

  # If you need to set environment variables for the OpenTelemetry Collector, you can do so by setting the `otel_env` variable:
  # otel_env = {
  #   "GOMEMLIMIT"  = "2750MiB" # set the memory limit for the OpenTelemetry Collector
  # }

  # We recommend to read the OpenTelemetry Collector documentation to understand the memory limiter processor configuration: https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/memorylimiterprocessor/README.md#best-practices

  # If you want to customize the memory limiter processor for the OpenTelemetry Collector, you can do so by setting the `otel_memory_limiter` variable:
  # otel_memory_limiter = {
  #   check_interval         = "1s"
  #   limit_percentage       = 70
  #   spike_limit_percentage = 30
  # }


  # If you want to customize the resources for the OpenTelemetry Collector container, you can do so by setting the `otel_resources` variable:
  # otel_resources = {
  #   requests = {
  #     cpu    = "100m"
  #     memory = "256Mi"
  #   }
  #   limits = {
  #     cpu    = "100m"
  #     memory = "256Mi"
  #   }
  # }

  # when configuring multiple providers for different clusters, you can configure the module to use to correct provider alias:
  providers = {
    kubernetes = kubernetes.<PROVIDER_ALIAS>
  }

  # If you want to set explicitly the NodeSelector for the OpenTelemetry Collector or the kube-state-metrics deployment, you can do so by setting the `otel_node_selector` and `kube_state_node_selector` variables:
  # otel_node_selector = {
  #   purpose = high-availability-node
  # }
  # kube_state_node_selector = {
  #   purpose = high-availability-node
  # }
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
| otel\_env | Environment variables to set for the OpenTelemetry Collector | `map(string)` | `{}` | no |
| otel\_memory\_limiter | Configuration for the memory limiter processor | <pre>object({<br>    check_interval         = string<br>    limit_percentage       = number<br>    spike_limit_percentage = number<br>  })</pre> | <pre>{<br>  "check_interval": "1s",<br>  "limit_percentage": 70,<br>  "spike_limit_percentage": 30<br>}</pre> | no |
| otel\_resources | Resources to set for the OpenTelemetry Collector container | <pre>object({<br>    requests = object({<br>      cpu    = optional(string)<br>      memory = optional(string)<br>    })<br>    limits = object({<br>      cpu    = optional(string)<br>      memory = optional(string)<br>    })<br>  })</pre> | <pre>{}</pre> | no |
| kube\_state\_node\_selector | Node Selector for the kube-state-metrics deployment | `map(string)` | `{}` | no |
| otel\_node\_selector | Node Selector for the otel OpenTelemetry Collector deployment | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| account\_id | The ID of the used AWS account |
| region | AWS region used |
| deployment\_id | Deployment ID as provided by DoiT |
| collector\_deployment | The Open Telemetry deployment name in the format of `namespace/name` |
| kube\_state\_metrics\_deployment | The `kube-state-metrics` deployment name in the format of `namespace/name` |
