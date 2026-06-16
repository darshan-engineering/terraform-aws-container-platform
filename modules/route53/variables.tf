variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "domain_name" {
  description = "Your Domain Name"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Zone ID. Created by applying bootstrap directory"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS Name"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB Zone ID"
  type        = string
}
