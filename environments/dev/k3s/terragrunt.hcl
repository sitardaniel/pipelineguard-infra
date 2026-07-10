# Single-node k3s cluster for dev - replaces managed EKS to cut the control
# plane fee and collapse the node group down to one instance, while keeping
# the Kubernetes/GitOps workflow identical.

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/k3s"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id            = "vpc-mock"
    vpc_cidr          = "10.0.0.0/16"
    public_subnet_ids = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
  }
}

inputs = {
  cluster_name  = "pipelineguard-dev"
  vpc_id        = dependency.vpc.outputs.vpc_id
  vpc_cidr      = dependency.vpc.outputs.vpc_cidr
  subnet_id     = dependency.vpc.outputs.public_subnet_ids[0]
  instance_type = "t3.medium"

  # Restrict the exposed NodePort (config-ui) to the deployer's own IP
  # instead of the module's 0.0.0.0/0 default.
  allowed_http_cidr = "176.229.31.250/32"
}
