#!/bin/bash

# Exit on error
set -e

# Define the base directory
BASE_DIR="live/prod"

# Step 1: Deploy the terraform_state module
echo "Deploying terraform_state module..."
cd "${BASE_DIR}/terraform_state"
terraform fmt
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -auto-approve
echo "terraform_state module deployed successfully."

# Step 2: Deploy modules
echo "Deploying modules..."
cd "../iam"
terraform fmt
terraform init
terraform plan
terraform apply -auto-approve

echo "All modules deployed successfully."