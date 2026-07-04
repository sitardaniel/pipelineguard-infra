# RDS module for dev environment

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-mock"
    vpc_cidr           = "10.0.0.0/16"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
  }
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_security_group_id = "sg-mock"
  }
}

inputs = {
  vpc_id                  = dependency.vpc.outputs.vpc_id
  vpc_cidr                = dependency.vpc.outputs.vpc_cidr
  subnet_ids              = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups = [dependency.eks.outputs.cluster_security_group_id]

  # Dev settings - smallest instance, no HA
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az          = false

  database_name     = "pipelineguard"
  database_username = "pipelineguard"
  # Password should come from environment variable or secrets manager
  # TF_VAR_database_password
}
