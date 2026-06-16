output "certificate_arn" {
  description = "ACM Certificate ARN"
  value       = module.acm.acm_certificate_arn
}

output "acm_certificate_status" {
  description = "Status of ACM Certificate"
  value       = module.acm.acm_certificate_status
}

output "acm_validation_route53_record_fqdns" {
  description = "Validation Route53 Record FQDNs"
  value       = module.acm.validation_route53_record_fqdns
}
