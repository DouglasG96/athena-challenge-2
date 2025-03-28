#!/bin/bash

# Exit on error
set -e

# Define the base directory
BASE_DIR="live/prod"

# Step 2: Destroy the ssm module
# echo "Destroying ssm module..."
# cd "${BASE_DIR}/ssm"
# terraform destroy -auto-approve
# echo "ssm module destroyed successfully."

# # Step 3: Destroy the s3 module
# echo "Destroying s3 module..."
# cd "../s3"
# terraform destroy -auto-approve
# echo "s3 module destroyed successfully."

# # Step 4: Destroy the iam module
# echo "Destroying iam module..."
# cd "../iam"
# terraform destroy -auto-approve
# echo "iam module destroyed successfully."

# Step 5: Destroy the terraform_state module
echo "Destroying terraform_state module..."
# cd "../terraform_state"
cd "${BASE_DIR}/terraform_state"
terraform destroy -auto-approve
echo "terraform_state module destroyed successfully."

echo "All modules destroyed successfully."