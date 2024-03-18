# Terraform module to deploy Doit EKS Lens feature to AWS

Clone the repository:
```bash
git clone https://github.com/doitintl/terraform-eks-lens.git

cd terraform-eks-lens
```

Configure the AWS and Kubernetes providers:
```hcl
# Configure the AWS Provider
provider "aws" {
    region     = "{cluster aws region}"
    access_key = "{aws access key}"
    secret_key = "{aws secret key}"
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}
```

Create a Doit API Key and set it as an environment variable:
https://console.doit.com/customers/{XXXXXXX}/profile/{YYYYYYYYY}/api

export DOIT_API_KEY=your-api-key

Run the following command to deploy:
```bash
./apply.sh
```

It will initialize the terraform workspace

Then it will ask for the following parameters:

    1. AWS Account ID
    2. AWS Region
    3. Cluster Name
    4. The OIDC Identity issuer URL for the cluster if You deploy the EKS cluster with OIDC identity provider enabled. You can provide the URL with `CLUSTER_OIDC_ISSUER_URL` environment variable.

Then it will download the `doit-eks-lens.tfvars` file with the doit API call using the `DOIT_API_KEY` environment variable. This file contains the feature configuration for the cluster.
For example:
```hcl
account_id       = "626859882963"
region           = "us-east-1"
cluster_name     = "eks-cluster-951"
deployment_id    = "BrWMlJOcrI1FguHdAzRR"
kube_state_image = "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2"
otel_image       = "otel/opentelemetry-collector-contrib:0.83.0"
ec2_cluster      = false
```

After that, it will apply the terraform configuration to create the Doit EKS Lens feature deployments.

```bash
terraform apply -var-file=<(cat doit-eks-lens.tfvars terraform.tfvars) -auto-approve
```

After the deployment is done, it will call the Doit API to enable the feature for the cluster.
