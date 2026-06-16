output "repository_arn" {
  value       = module.ecr.repository_arn
  description = "The full Amazon Resource Name (ARN) of the generated ECR repository resource layer."
}

output "repository_url" {
  value       = module.ecr.repository_url
  description = "The absolute URL pointing directly to the remote registry instance. (Format: [account_id].dkr.ecr.[region].amazonaws.com/[repo_name]). Use this value to direct your local `docker push/pull` commands."
}

output "repository_registry_id" {
  value       = module.ecr.repository_registry_id
  description = "The precise AWS Account ID associated with the primary workspace registry."
}
