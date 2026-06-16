output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_blocks" {
  description = "VPC CIDR BLOCKS"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "PUBLIC SUBNETS IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "PRIVATE SUBNET IDs"
  value       = module.vpc.private_subnets
}

output "azs" {
  description = "Available Availability Zones"
  value       = module.vpc.azs
}

output "database_subnet_group" {
  description = "Database Subnet Group"
  value       = module.vpc.database_subnet_group
}
