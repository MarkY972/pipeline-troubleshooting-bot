# Root Terraform variable definitions.
# These variables configure the overall deployment, including network and EKS cluster settings,
# by providing inputs to the local modules.

variable "aws_region" {
  description = "AWS region for deploying all resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "A name for the project, used for tagging and naming resources (e.g., VPC name)"
  type        = string
  default     = "cicd-ai-assistant"
}

variable "common_tags" {
  description = "Common tags to apply to all resources created by the modules"
  type        = map(string)
  default = {
    Project     = "Intelligent CI/CD Troubleshooting Assistant"
    Environment = "dev" # Can be overridden for different stages
    Terraform   = "true"
  }
}

// VPC / Network specific variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of Availability Zones to use from the region (e.g., 2 or 3)"
  type        = number
  default     = 2 # Using 2 for cost optimization in demo, typically 3 for prod
  validation {
    condition     = var.num_azs >= 2 && var.num_azs <= 3 # Common practice
    error_message = "Number of AZs must be 2 or 3."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets. Must match the number of AZs."
  type        = list(string)
  # Default values should correspond to var.num_azs
  # Example for num_azs = 2:
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  # Example for num_azs = 3:
  # default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets. Must match the number of AZs."
  type        = list(string)
  # Default values should correspond to var.num_azs
  # Example for num_azs = 2:
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  # Example for num_azs = 3:
  # default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

// EKS Cluster specific variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "ai-eks-cluster"
}

variable "eks_version" {
  description = "Desired Kubernetes version for the EKS Cluster"
  type        = string
  default     = "1.27" # Check for latest supported versions
}

// EKS Node Group specific variables
variable "node_instance_types" {
  description = "List of EC2 instance types for the EKS worker nodes (e.g., [\"t3.medium\"])"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes in the default node group"
  type        = number
  default     = 2
}

variable "node_min_capacity" {
  description = "Minimum number of worker nodes in the default node group"
  type        = number
  default     = 1
}

variable "node_max_capacity" {
  description = "Maximum number of worker nodes in the default node group"
  type        = number
  default     = 3
}

variable "aws_auth_roles" {
  description = "List of IAM roles to grant access to the EKS cluster via aws-auth configmap. Set `system:masters` for admin access."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    # Example:
    # {
    #   rolearn  = "arn:aws:iam::ACCOUNT_ID:role/YourClusterAdminRole"
    #   username = "admin-role"
    #   groups   = ["system:masters"]
    # }
  ]
  # Note: To allow the EKS node IAM role to connect to the cluster (necessary for nodes to join),
  # the EKS module typically handles this automatically if `manage_aws_auth_configmap = true`.
  # Explicitly adding node roles here is usually not needed for basic functionality.
}
