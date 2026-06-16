module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 5.0"

  zone_id = var.route53_zone_id

  records = [
    {
      name = ""
      type = "A"

      alias = {
        name                   = var.alb_dns_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
      }
    },

    {
      name = "www"
      type = "A"

      alias = {
        name                   = var.alb_dns_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
      }
    }
  ]
}
