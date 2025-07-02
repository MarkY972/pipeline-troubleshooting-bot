# Main Terraform configuration for the EKS (Elastic Kubernetes Service) cluster.
# This file defines the EKS cluster itself using the terraform-aws-modules/eks/aws module.
# It depends on the VPC created in vpc.tf.
#
# Note: This configuration is intended for demonstrating the CI/CD pipeline structure
# and AI troubleshooting. It defines resources but the pipeline is set up for
# `terraform plan` only, not `terraform apply` (actual deployment).

provider "aws" {
  region = var.aws_region
}

# Placeholder for EKS cluster resources
# We will use the terraform-aws-modules/eks/aws module

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3" # Specify a version for consistency

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # EKS best practice: control plane in private subnets

  eks_managed_node_groups = {
    default = {
      instance_type = var.instance_type
      min_size      = var.min_capacity
      max_size      = var.max_capacity
      desired_size  = var.desired_capacity

      # Additional configurations can be added here
      # e.g., disk_size, ami_type, labels, taints
      tags = {
        TerraformManaged = "true"
      }
    }
  }

  # Required for cluster communication with worker nodes
  # and for kubectl access if you were to deploy this.
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    # You can add IAM roles here that should have access to the cluster
    # Example:
    # {
    #   rolearn  = "arn:aws:iam::ACCOUNT_ID:role/YourAdminRole"
    #   username = "admin"
    #   groups   = ["system:masters"]
    # }
  ]

  tags = {
    Environment = "dev"
    Project     = "eks-troubleshooting-assistant"
  }
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name."
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}
