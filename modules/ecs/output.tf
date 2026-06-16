output "cluster_name" {
  description = "ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = module.ecs.cluster_arn
}

output "service_name" {
  description = "ECS Service Name"
  value       = module.ecs.services["app"].name
}

output "service_arn" {
  description = "ECS Service ARN"
  value       = module.ecs.services["app"].id
}

output "task_definition_arn" {
  description = "Task Definition ARN"
  value       = module.ecs.services["app"].task_definition_arn
}

output "task_execution_role_arn" {
  description = "Task Execution Role ARN"
  value       = module.ecs.task_exec_iam_role_arn
}
