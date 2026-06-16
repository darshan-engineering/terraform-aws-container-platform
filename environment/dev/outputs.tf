# ---------- VPC / SG -------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# output "public_subnets" {
#   description = "Public subnet IDs"
#   value       = module.vpc.public_subnets
# }

# output "private_subnets" {
#   description = "Private subnet IDs"
#   value       = module.vpc.private_subnets
# }

# output "ecs_sg_id" {
#   description = "App Security Group ID"
#   value       = module.sg.ecs_sg_id
# }

# output "alb_sg_id" {
#   description = "ALB Security Group ID"
#   value       = module.sg.alb_sg_id
# }

# ---------- ACM -------------
# output "certificate_arn" {
#   description = "ACM Certificate ARN"
#   value       = module.acm.certificate_arn
# }

output "acm_certificate_status" {
  description = "Status of ACM Certificate"
  value       = module.acm.acm_certificate_status
}

# output "acm_validation_route53_record_fqdns" {
#   description = "Validation Route53 Record FQDNs"
#   value       = module.acm.acm_validation_route53_record_fqdns
# }

# ---------- ALB -------------

# Load Balancer
# output "alb_id" {
#   description = "The ID and ARN of the load balancer we created"
#   value       = module.alb.alb_id
# }

output "alb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.alb_arn
}

# output "alb_arn_suffix" {
#   description = "ARN suffix of our load balancer - can be used with CloudWatch"
#   value       = module.alb.alb_arn_suffix
# }

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

# output "alb_zone_id" {
#   description = "ALB Zone ID"
#   value       = module.alb.alb_zone_id
# }

# -----------------------
# Target Group(s)

# output "target_groups" {
#   description = "Map of target groups created and their attributes"
#   value       = module.alb.target_groups
# }


# ---------- ECR -------------
# output "repository_arn" {
#   value       = module.ecr.repository_arn
#   description = "The full Amazon Resource Name (ARN) of the generated ECR repository resource layer."
# }

output "repository_url" {
  value       = module.ecr.repository_url
  description = "The absolute URL pointing directly to the remote registry instance. (Format: [account_id].dkr.ecr.[region].amazonaws.com/[repo_name]). Use this value to direct your local `docker push/pull` commands."
}

# output "repository_registry_id" {
#   value       = module.ecr.repository_registry_id
#   description = "The precise AWS Account ID associated with the primary workspace registry."
# }


# ---------- ECS -------------
# output "cluster_arn" {
#   description = "ARN of the ECS cluster."
#   value       = module.ecs.cluster_arn
# }

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

# output "service_name" {
#   description = "Name of the ECS service."
#   value       = module.ecs.service_name
# }

# output "service_arn" {
#   description = "ARN of the ECS service."
#   value       = module.ecs.services["app"].arn
# }

output "task_execution_role_arn" {
  description = "Task Execution Role ARN"
  value       = module.ecs.task_execution_role_arn
}


# ---------- Route53 -----------
output "route53_record_name" {
  value = module.route53.route53_record_name
}

# output "route53_record_fqdn" {
#   value = module.route53.route53_record_fqdn
# }

# ---------- WAF -----------
output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.waf.web_acl_arn
}

# output "web_acl_id" {
#   description = "ID of the WAF Web ACL"
#   value       = module.waf.web_acl_id
# }
