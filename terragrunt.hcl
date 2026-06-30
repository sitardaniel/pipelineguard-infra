# Root Terragrunt configuration for PipelineGuard
# This file contains common configuration inherited by all child modules

locals {
  # Parse the environment from the path
  parsed = regex(".*/environments/(?P<env>[^/]+)/.*", get_terragrunt_dir())
  environment = local.parsed.env

  # Common variables
  project = "pipelineguard"
  region  = "us-east-1"
}

# Configure remote state
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "pipelineguard-tf-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "pipelineguard-tf-locks"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "${local.region}"

  default_tags {
    tags = {
      Project     = "${local.project}"
      Environment = "${local.environment}"
      ManagedBy   = "terragrunt"
    }
  }
}
EOF
}

# Common inputs passed to all modules
inputs = {
  project     = local.project
  environment = local.environment
  region      = local.region
}
