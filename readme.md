# 🚀 Terraform AWS Infrastructure Deployment

This project automates the deployment of a scalable and secure AWS infrastructure using Terraform.
---

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

### 1. **Terraform** 🛠️  
Install Terraform from the [official website](https://www.terraform.io/downloads.html).

### 2. **AWS CLI** 🔑  
Install the AWS CLI from the [official guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

### 3. **IAM Credentials** 🔒  
Create an IAM user with programmatic access and the following permissions:
   - `IAMFullAccess`
   - `AmazonS3FullAccess`
   - `AmazonSSMFullAccess`

Save the **Access Key ID** and **Secret Access Key** for the next steps.

---

## 🛠️ Setup Instructions

### 1. Configure AWS CLI
Run the following command to set up your AWS CLI with IAM credentials:

```bash
aws configure --profile default
```

- **AWS Access Key ID**: Paste your Access Key ID.
- **AWS Secret Access Key**: Paste your Secret Access Key.
- **Default region name**: Enter `us-east-1` (or your preferred region).
- **Default output format**: Leave blank or enter `json`.

### 2. Update `.tfvars` File
Modify the `terraform.tfvars` file with your specific values:

```hcl
profile = "default"  # Your AWS CLI profile name
region  = "us-east-1"    # AWS region to deploy resources
```


### 3. Deploy the Infrastructure
Execute the following script to create the AWS resources:

```bash
./deploy_prod.sh
```

Note: If you have any issues you should set permissions for execution to the script with the following command:

```bash
chmod +x ./deploy_prod.sh
```

---

## 🛑 Destroying the Infrastructure

To avoid unnecessary charges, destroy the infrastructure when you're done:

```bash
./destroy_prod.sh
```

Note: If you have any issues you should set permissions for execution to the script with the following command:

```bash
chmod +x ./destroy_prod.sh
```

---

## 📂 Project Structure

```bash
.
├── live/
│   ├── prod/
│   │   ├── main.tf #Where the module is called
│   │   └── outputs.tf #Values after deployed infrastructure
│   │   └── provider.tf #Provider configuration 
│   │   └── terraform.tfvars #Specific and needed values for infrastructure
│   │   ├── variables.tf #Variables of the module
│   │   ├── terraform_state/
│   │   │   ├── main.tf
│   │   │   ├──outputs.tf
│   │   │   ├──terraform.tfvars
│   │   │   ├──variables.tf
├── modules/
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecs/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── monitoring/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
├── deploy_prod.sh              # Script for automating infrastructure creation
├── destroy_prod.sh             # Script for automating infrastructure destruction
├── README.md              # Project documentation
└── .gitignore             # Files to ignore in Git
```
---

### Notes:
- **This project uses the remote state approach**: It creates a S3 bucket to save the terraform state file (tfstate) and you must define the sctructure of your folders within S3 bucket.

### Workflow Overview:
- **Terraform Lint & Validate**: Ensures Terraform code is correctly formatted.
- **Terraform Plan**: Generates an execution plan for review.
- **Terraform Apply**: Deploys changes if approved.
- **Terraform Destroy**: Destroys infrastructure if approved.

## 🙏 Acknowledgments

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

Happy deploying! 🎉