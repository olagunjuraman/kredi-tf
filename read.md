# AWS Infrastructure Deployment with Terraform

This guide covers the steps to deploy an Amazon EKS cluster and a PostgreSQL database using Terraform. It ensures that anyone with basic knowledge of AWS and Terraform can successfully deploy and manage the necessary resources.

## Prerequisites

Before you begin, ensure you have the following:

- **AWS Account**: Create an account at [AWS](https://aws.amazon.com).
- **Terraform Installed**: Download and install the Terraform CLI from [Terraform's website](https://www.terraform.io/downloads.html).
- **AWS CLI Installed**: Useful for configuring credentials. Install from [AWS CLI](https://aws.amazon.com/cli/).
- **kubectl Installed**: Required to interact with the Kubernetes cluster. Instructions are available [here](https://kubernetes.io/docs/tasks/tools/).

## Configuration

### Step 1: Configure AWS CLI

Set up your AWS CLI with the appropriate credentials. This is crucial for Terraform to interact with your AWS account:


aws configure




### Step 2: Clone the Repository

git clone https://your-repository-url.com/path/to/repo.git
cd into-your-repository

### Step 3: Set Up Terraform Variables
 Set environment variables to define sensitive data into database 
example
db_username         = "admin"
db_password         = "strongpassword123"

### Step 4: Initialize Terraform
Initialize the Terraform environment to download the required providers and modules:
terraform init


### Step 4: Plan Terraform
terraform plan


### Step 6: Deploy the Infrastructure

terraform apply
