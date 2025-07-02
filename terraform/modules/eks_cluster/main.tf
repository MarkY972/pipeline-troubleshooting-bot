# Terraform configuration for the EKS (Elastic Kubernetes Service) cluster.
# This local module defines the EKS cluster using the public terraform-aws-modules/eks/aws module.

# Provider configuration is inherited from the root module.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3" # Specify a version for consistency

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids # Typically private subnets for EKS control plane and nodes

  eks_managed_node_groups = {
    for k, v in var.eks_managed_node_groups : k => {
      instance_types = v.instance_types       # Changed from instance_type to instance_types (list)
      min_size       = v.min_size
      max_size       = v.max_size
      desired_size   = v.desired_size
      disk_size      = v.disk_size
      ami_type       = v.ami_type
      labels         = v.labels
      # Add other node group parameters as needed from var.eks_managed_node_groups structure
      tags           = merge(var.common_tags, v.tags, { Name = "${var.cluster_name}-node-group-${k}" })
    }
  }

  # Example of how to configure aws-auth configmap through the module
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_roles            = var.aws_auth_roles
  aws_auth_users            = var.aws_auth_users
  aws_auth_accounts         = var.aws_auth_accounts

  # Fargate profiles (example, if needed)
  # fargate_profiles = var.fargate_profiles

  tags = merge(var.common_tags, {
    Name = var.cluster_name
  })
}
