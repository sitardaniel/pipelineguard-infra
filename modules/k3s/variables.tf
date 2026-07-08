variable "project" {
  description = "Project name"
  type        = string
  default     = "pipelineguard"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name for the k3s node (used in tags)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used to scope security group egress"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for the node - no NAT gateway needed since it has a direct IGW route"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the single-node cluster"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB (needs room for k3s + built container images)"
  type        = number
  default     = 20
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach exposed NodePorts (e.g. config-ui). Access to the node itself is via SSM Session Manager, not SSH."
  type        = string
  default     = "0.0.0.0/0"
}

variable "nodeports" {
  description = "NodePorts to expose to allowed_http_cidr"
  type        = list(number)
  default     = [30090]
}
