# EKS module for prod environment

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-mock"
    vpc_cidr           = "10.1.0.0/16"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
  }
}

inputs = {
  cluster_name       = "pipelineguard-prod"
  kubernetes_version = "1.29"
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_cidr           = dependency.vpc.outputs.vpc_cidr
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids

  # Prod settings - larger instances, on-demand for reliability
  instance_types = ["t3.large"]
  capacity_type  = "ON_DEMAND"
  desired_size   = 3
  min_size       = 2
  max_size       = 6
}
