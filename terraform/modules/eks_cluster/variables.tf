variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and worker nodes"
  type        = list(string)
}

variable "eks_managed_node_groups" {
  description = "Configuration for EKS managed node groups"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    ami_type       = string
    labels         = map(string)
    tags           = map(string)
    # Add other configurable parameters for node groups as needed
  }))
  default = {}
}

variable "manage_aws_auth_configmap" {
  description = "Whether to manage the aws-auth configmap through the EKS module"
  type        = bool
  default     = true
}

variable "aws_auth_roles" {
  description = "List of IAM roles to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_accounts" {
  description = "List of AWS accounts to add to the aws-auth configmap"
  type        = list(string)
  default     = []
}

# Example for Fargate profiles, if you plan to use them
# variable "fargate_profiles" {
#   description = "Map of Fargate profiles to create"
#   type = map(object({
#     name      = string
#     selectors = list(object({
#       namespace = string
#       labels    = map(string)
#     }))
#     subnet_ids = list(string) # Optional: defaults to cluster subnets
#     tags       = map(string)
#   }))
#   default = {}
# }

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
