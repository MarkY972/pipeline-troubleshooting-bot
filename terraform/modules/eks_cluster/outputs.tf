output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_security_group_id" {
  description = "The ID of the EKS cluster security group"
  value       = module.eks.cluster_security_group_id
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of AutoScaling Group names of EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

output "eks_managed_node_group_iam_role_arns" {
  description = "ARNs of IAM roles for EKS managed node groups"
  value       = { for k, v in module.eks.eks_managed_node_groups : k => v.iam_role_arn }
}

# Add other outputs as needed, for example:
# output "cluster_certificate_authority_data" {
#   description = "Base64 encoded certificate data required to communicate with the cluster"
#   value       = module.eks.cluster_certificate_authority_data
#   sensitive   = true # Be careful with sensitive outputs
# }
