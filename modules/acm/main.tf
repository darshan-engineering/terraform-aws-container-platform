module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = var.domain_name
  zone_id     = var.route53_zone_id # Route53 Zone ID

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  validation_method = "DNS"

  wait_for_validation = true

  tags = var.tags
}
