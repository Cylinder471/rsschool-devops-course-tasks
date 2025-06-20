terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }

  required_version = ">= 1.11.3"
}

provider "aws" {
  profile = "devops"
  region  = "us-east-1"
}
