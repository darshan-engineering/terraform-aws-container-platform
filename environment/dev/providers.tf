terraform {
  required_version = ">= 1.15.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.50.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = local.aws_region
}
