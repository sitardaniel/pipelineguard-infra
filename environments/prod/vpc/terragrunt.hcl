# VPC module for prod environment

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_cidr     = "10.1.0.0/16"
  cluster_name = "pipelineguard-prod"
}
