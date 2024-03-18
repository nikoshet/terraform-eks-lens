#!/bin/bash

# Check if DOIT_API_KEY is set
if [ -z "${DOIT_API_KEY}" ]; then
  echo "DOIT_API_KEY is not set"
  read -p "Enter DOIT_API_KEY: " DOIT_API_KEY
fi

# check if terraform.tfvars is present
if [ ! -f "doit-eks-lens.tfvars" ]; then
  echo "doit-eks-lens.tfvars is not present"

  if  [ -z "${ACCOUNT_ID}" ]; then
    read -p "Enter AWS account_id: " ACCOUNT_ID
  fi

  if  [ -z "${REGION}" ]; then
    read -p "Enter AWS region: " REGION
  fi

  if  [ -z "${CLUSTER_NAME}" ]; then
    read -p "Enter AWS cluster_name: " CLUSTER_NAME
  fi

  # download doit-eks-lens.tfvars
  curl -o doit-eks-lens.tfvars -X POST -H "Authorization: Bearer ${DOIT_API_KEY}" -H "Content-Type: application/json" -d "{\"account_id\": \"${ACCOUNT_ID}\",\"region\": \"${REGION}\",\"cluster_name\": \"${CLUSTER_NAME}\"}" http://localhost:8086/doit-eks-lens-tfvars
fi

# show the terraform plan
# terraform plan -var-file=<(cat doit-eks-lens.tfvars terraform.tfvars) #-out=eks-lens.plan

terraform apply -var-file=<(cat doit-eks-lens.tfvars terraform.tfvars) -auto-approve # eks-lens.plan


# check if terraform apply was successful
if [ $? -eq 0 ]; then
    echo "Successfully applied terraform configuration"

    account_id=$(terraform output account_id)
    region=$(terraform output region)
    cluster_name=$(terraform output cluster_name)
    deployment_id=$(terraform output deployment_id)

    echo "Validating s3 bucket data"

    curl -X POST -H "Authorization: Bearer ${DOIT_API_KEY}" -H "Content-Type: application/json" -d "{\"account_id\": ${account_id},\"region\": ${region},\"cluster_name\": ${cluster_name}, \"deployment_id\": ${deployment_id}}" http://localhost:8086/terraform-validate
fi

