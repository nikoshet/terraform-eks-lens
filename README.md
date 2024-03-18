# Terraform module to deploy Doit EKS Lens feature to AWS

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
    3. EKSCluster Name
    4. The OIDC Identity issuer URL for the cluster if You deploy the EKS cluster with OIDC identity provider enabled.

Then it will download the `doit-eks-lens.tfvars` file with the doit API call using the `DOIT_API_KEY` environment variable.

After that, it will apply the terraform configuration to create the Doit EKS Lens feature deployments.
```bash
terraform apply -var-file=<(cat doit-eks-lens.tfvars terraform.tfvars) -auto-approve
```

After the deployment is done, it will call the Doit API to enable the feature for the cluster.
