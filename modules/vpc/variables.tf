variable "project" {
  description = "Project name"
  type        = string
  default     = "pipelineguard"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the cluster (for subnet tagging)"
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway for the private subnets. Skip it when nothing in the private subnets needs outbound internet access (e.g. a k3s node living in the public subnet, with RDS staying VPC-internal)."
  type        = bool
  default     = true
}
