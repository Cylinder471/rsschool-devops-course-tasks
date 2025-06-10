terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }
  required_version = ">= 1.11.3"
  backend "s3" {
    bucket  = "rsschool-devops-course-tasks"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    profile = "devops"
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

