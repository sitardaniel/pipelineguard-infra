# VPC module for dev environment

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_cidr           = "10.0.0.0/16"
  cluster_name       = "pipelineguard-dev"
  create_nat_gateway = false # k3s node lives in the public subnet; RDS never needs internet egress
}
