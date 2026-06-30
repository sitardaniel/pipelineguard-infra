# ECR module for dev environment

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecr"
}

inputs = {
  repository_names = [
    "trivy-scanner",
    "checkov-scanner",
    "gitleaks-scanner",
    "grype-scanner",
    "result-normalizer",
    "webhook-receiver"
  ]
}
