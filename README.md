# 🛡️ PipelineGuard - Infrastructure

> Terraform + Terragrunt configuration for PipelineGuard's AWS infrastructure. Spun up on-demand for demos, torn down immediately after to minimize cost.

[![IaC: Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)](https://www.terraform.io/)
[![Config: Terragrunt](https://img.shields.io/badge/config-Terragrunt-green)](https://terragrunt.gruntwork.io/)
[![Cloud: AWS](https://img.shields.io/badge/cloud-AWS-FF9900)](https://aws.amazon.com/)
[![Scanned: Checkov](https://img.shields.io/badge/scanned-Checkov-blue)](https://www.checkov.io/)

---

## What This Repo Contains

All AWS infrastructure for PipelineGuard, defined as code using Terraform modules and orchestrated with Terragrunt.

| Repo | Purpose |
|------|---------|
| [`pipelineguard-app`](https://github.com/sitardaniel/pipelineguard-app) | Scanner source code + Dockerfiles |
| [`pipelineguard-gitops`](https://github.com/sitardaniel/pipelineguard-gitops) | Kubernetes manifests + Argo CD apps |
| **`pipelineguard-infra`** (this repo) | Terraform/Terragrunt for AWS |

---

## Infrastructure Components

| Component       | AWS Service       | Notes                              |
|-----------------|-------------------|------------------------------------|
| Kubernetes      | EKS               | Demo cluster, on-demand only       |
| Container images| ECR               | Private registry per scanner image |
| Database        | RDS PostgreSQL    | Findings storage                   |
| Secrets         | Vault on EKS      | Not AWS Secrets Manager            |
| State backend   | S3 + DynamoDB     | Terragrunt remote state + locking  |
| Networking      | VPC, subnets, SGs | Private subnets for EKS nodes      |

---

## Repository Structure

```
pipelineguard-infra/
├── modules/
│   ├── eks/                  # EKS cluster module
│   ├── rds/                  # PostgreSQL RDS module
│   ├── ecr/                  # ECR repositories module
│   ├── vpc/                  # VPC + networking module
│   └── s3-state/             # Remote state backend module
├── live/
│   └── aws/
│       └── demo/             # Demo environment (only env that gets deployed)
│           ├── terragrunt.hcl
│           ├── eks/
│           │   └── terragrunt.hcl
│           ├── rds/
│           │   └── terragrunt.hcl
│           ├── ecr/
│           │   └── terragrunt.hcl
│           └── vpc/
│               └── terragrunt.hcl
├── terragrunt.hcl            # Root terragrunt config
├── .github/
│   └── ISSUE_TEMPLATE/
├── .gitignore
├── SECURITY.md
└── README.md
```

---

## Cost Model

This infrastructure is designed to cost **~$5–15 per demo session**, not per month.

| Component    | Strategy                              | Cost          |
|--------------|---------------------------------------|---------------|
| EKS cluster  | `terragrunt run-all apply` → demo → `terragrunt run-all destroy` | ~$0.10/hr |
| RDS          | `db.t3.micro`, destroyed after demo   | ~$0.02/hr |
| ECR          | Images stored between sessions        | ~$0.01/GB/mo |
| VPC/NAT      | Destroyed with cluster                | ~$0.045/hr |
| **Total**    | ~2hr demo session                     | **~$5–15**    |

---

## Usage

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.50
- AWS CLI configured (`aws configure`)
- AWS account with appropriate IAM permissions

### Spin Up (Demo)

```bash
cd live/aws/demo

# Plan everything
terragrunt run-all plan

# Apply everything (VPC → EKS → RDS → ECR in dependency order)
terragrunt run-all apply
```

### Tear Down (After Demo)

```bash
cd live/aws/demo

# Destroy everything in reverse dependency order
terragrunt run-all destroy
```

> ⚠️ Always run `destroy` after a demo to avoid ongoing charges.

### Remote State Bootstrap (One-time)

```bash
cd modules/s3-state
terraform init && terraform apply
```

---

## Security

- All Terraform files are scanned by Checkov via PipelineGuard itself (dogfooding)
- State files are encrypted at rest in S3
- DynamoDB table prevents concurrent state modifications
- IAM roles follow least-privilege principle
- No AWS credentials are stored in this repo - use AWS CLI profiles or IAM roles

See [SECURITY.md](SECURITY.md) for the full policy.
