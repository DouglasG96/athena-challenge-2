#!/bin/bash

# Exit on error
set -e

# Define the base directory
BASE_DIR="live/prod"

# Step 1: Destroy production modules
echo "Destroying production modules..."
cd "${BASE_DIR}"
terraform destroy -auto-approve
echo "production modules destroyed successfully."

# Step 2: Destroy the terraform_state module
echo "Destroying terraform_state module..."
cd "${BASE_DIR}/terraform_state"
terraform destroy -auto-approve
echo "terraform_state module destroyed successfully."

echo "All modules destroyed successfully."