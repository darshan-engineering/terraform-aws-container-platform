terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# -------------------------------------
# Local Variables
locals {
  domain_name = "atkaridarshan.online"

  tags = {
    ManagedBy = "Terraform"
    Owner     = "Darshan Atkari"
  }
}
# -------------------------------------
# Create a Route53 Hosted Zone for the domain
module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 5.0"

  # WARNING:
  # Deleting this will destroy the Route53 hosted zone
  # and generate new nameservers on recreation.
  # If recreated, update the registrar (GoDaddy) nameservers.

  zones = {
    (local.domain_name) = {
      comment = "Hosted zone for ${local.domain_name}"
    }
  }

  tags = local.tags
}


# -------------------------------------
# Generate a 6-Character Random Suffix
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

module "dev_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "tfstate-${random_string.suffix.result}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  # Allow deletion of non-empty bucket
  # force_destroy = true

  versioning = {
    enabled = true
  }

  tags = local.tags
}


# ------------------------------------
output "dev_tfstate_bucket_name" {
  description = "Dev Env Terraform State file Bucket name"
  value       = module.dev_s3_bucket.s3_bucket_id # Gives Bucket Name
}

output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = module.zone.route53_zone_zone_id[local.domain_name]
}

output "name_servers" {
  description = "Route53 nameservers to configure at the domain registrar"
  value       = module.zone.route53_zone_name_servers[local.domain_name]
}
