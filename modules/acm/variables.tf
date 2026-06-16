variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "domain_name" {
  description = "Your Domain Name"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Zone ID"
  type        = string
}
