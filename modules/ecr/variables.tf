variable "project" {
  description = "Project name"
  type        = string
  default     = "pipelineguard"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default = [
    "trivy-scanner",
    "checkov-scanner",
    "gitleaks-scanner",
    "grype-scanner",
    "result-normalizer",
    "webhook-receiver"
  ]
}
