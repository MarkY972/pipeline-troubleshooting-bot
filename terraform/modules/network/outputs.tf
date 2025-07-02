output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "database_subnets_ids" {
  description = "List of IDs of database subnets (if created by the VPC module)"
  value       = module.vpc.database_subnets
  # This output depends on whether database_subnets are enabled in the vpc module call.
  # If not, this might result in an error or empty list.
  # Consider adding a condition or ensuring they are always created if needed.
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}
