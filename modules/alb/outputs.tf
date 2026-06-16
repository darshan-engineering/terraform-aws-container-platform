# Load Balancer
output "alb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.id
}

output "alb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = module.alb.arn_suffix
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = module.alb.zone_id
}

# -----------------------
# Target Group(s)

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = module.alb.target_groups
}
