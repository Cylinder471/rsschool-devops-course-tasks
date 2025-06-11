AWS Account Configuration and Terraform Deployment
Overview
This repository contains Terraform configurations to set up an AWS account with necessary permissions and security configurations, deploy S3 buckets for Terraform states, and create a GitHub Actions workflow for continuous deployment.


Table of Contents
Prerequisites
Installation
AWS Configuration
Terraform Setup
GitHub Actions Workflow
Usage
Verification
License
Prerequisites
An AWS account
GitHub account
AWS CLI installed (version 2)
Terraform installed (version 1.6+)
Installation
Install AWS CLI: Follow the instructions here.
Install Terraform: Follow the instructions here.
(Optional) Configure tfenv for managing Terraform versions here.
Important: 1-install-tools folder contains a screenshot of the install tools

AWS Configuration
Create an IAM User:
Navigate to IAM in the AWS Console.
Create a user with the following policies:
AmazonEC2FullAccess
AmazonRoute53FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
AmazonSQSFullAccess
AmazonEventBridgeFullAccess
Enable MFA for the user.
Important: 2-create-user-MFA folder contains a screenshot of the created user

Configure AWS CLI:

Use the new user's credentials to configure the AWS CLI:
aws configure
Verify the Configuration:

Run the command:
aws ec2 describe-instance-types --instance-types t4g.nano
Important: The result of this command is in the 3-configure-aws-cli folder

Terraform Setup
Bucket for Terraform States:

A dedicated S3 bucket is created for managing Terraform states.
You can take a look at the contents of the code in the s3-terraform-states folder
IAM Role for GitHub Actions:

An IAM role GithubActionsRole is created with necessary permissions and trust policies configured for GitHub.
You can take a look at the contents of the code in the roles folder
Directory Structure:

The Terraform code is organized into separate files for better maintainability.
Variables are defined in a separate variables.tf file.
Create test resources

I have created a test resource. If you look at the code, I didn't create much except the key for the backend and I linked this test environment to the pipeline. You can view the code in the test-resources folder
GitHub Actions Workflow
A GitHub Actions workflow is set up to handle the deployment process with the following jobs:
terraform-init: Runs terraform init for initializes a working directory.
terraform-check: Runs terraform fmt for formatting checks.
terraform-plan: Runs terraform plan for planning deployments.
terraform-apply: Runs terraform apply for deploying infrastructure.
Usage
To deploy the infrastructure:

Push your changes to the default branch or create a pull request.
The GitHub Actions workflow will automatically run the defined jobs.
