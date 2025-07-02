# Terraform output definitions.
# This file defines outputs that can be easily queried after `terraform apply`.
# While `terraform apply` is not part of the current pipeline setup (only `plan`),
# defining outputs is good practice. Some key outputs are re-exported here for clarity,
# though they are also available directly from their respective module definitions in
# `vpc.tf` and `main.tf`.

output "vpc_id_output" {
  description = "The ID of the VPC created for the EKS cluster."
  value       = module.vpc.vpc_id
}

output "eks_cluster_name_output" {
  description = "The name of the provisioned EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint_output" {
  description = "The endpoint URL for the EKS cluster's Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "eks_managed_node_group_iam_role_arn_output" {
  description = "IAM role ARN for the EKS managed node group."
  # This demonstrates accessing a deeper output from the EKS module.
  # The exact output name might vary based on module version and configuration.
  # Example: value = module.eks.eks_managed_node_groups["default"].iam_role_arn
  # For the current EKS module version, it might be nested differently or part of a combined output.
  # This is a placeholder to show how one might output such details.
  # Actual value may need adjustment based on inspecting `terraform output` after a successful plan/apply.
  value       = "To be determined: Check EKS module outputs for specific node group role ARN"
}

# Additional outputs can be added here as the infrastructure evolves.
# For example, OIDC provider URL, specific security group IDs, etc.
