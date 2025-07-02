# Root Terraform output definitions.
# These outputs expose key information from the deployed infrastructure,
# sourced from the local network and EKS cluster modules.

output "vpc_id" {
  description = "The ID of the VPC created."
  value       = module.network.vpc_id
}

output "vpc_public_subnet_ids" {
  description = "List of IDs of public subnets in the VPC."
  value       = module.network.public_subnet_ids
}

output "vpc_private_subnet_ids" {
  description = "List of IDs of private subnets in the VPC."
  value       = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  description = "The name of the provisioned EKS cluster."
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster's Kubernetes API server."
  value       = module.eks_cluster.cluster_endpoint
  sensitive   = true # Endpoint can be considered sensitive
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster, used for IAM roles for service accounts."
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "eks_cluster_security_group_id" {
  description = "The ID of the EKS cluster's primary security group."
  value       = module.eks_cluster.cluster_security_group_id
}

output "eks_node_group_iam_role_arns" {
  description = "ARNs of IAM roles associated with the EKS managed node groups."
  value       = module.eks_cluster.eks_managed_node_group_iam_role_arns
}

# Example of how to output a specific node group's role ARN if you know the key:
# output "default_node_group_iam_role_arn" {
#   description = "ARN of the IAM role for the 'default_group' EKS managed node group."
#   value       = module.eks_cluster.eks_managed_node_group_iam_role_arns["default_group"]
#   # This assumes 'default_group' is a key in var.eks_managed_node_groups passed to the module.
# }
