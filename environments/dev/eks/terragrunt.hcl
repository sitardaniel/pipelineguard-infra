# EKS module for dev environment

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
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
  }
}

inputs = {
  cluster_name       = "pipelineguard-dev"
  kubernetes_version = "1.29"
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids

  # Dev settings - smaller, spot instances for cost savings
  instance_types = ["t3.medium"]
  capacity_type  = "SPOT"
  desired_size   = 2
  min_size       = 1
  max_size       = 4
}
