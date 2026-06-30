# Security Policy

## Supported Versions

PipelineGuard infrastructure is actively maintained on the `main` branch only.

| Version | Supported |
|---------|-----------|
| main    | ✅        |

---

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Report issues privately via the [Security Advisories](../../security/advisories/new) tab.

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (optional)

Response timeline:
- **Acknowledgement**: within 48 hours
- **Status update**: within 7 days
- **Resolution**: within 30 days for critical issues

---

## Infrastructure Security Practices

- **No credentials in Git** - AWS credentials are never stored in this repo; use IAM roles or AWS CLI profiles
- **Encrypted state** - Terraform state is encrypted at rest in S3 with server-side encryption
- **State locking** - DynamoDB prevents concurrent modifications
- **IaC scanning** - All Terraform files are scanned by Checkov (PipelineGuard scans itself)
- **Least privilege IAM** - All IAM roles follow minimum required permissions
- **Private networking** - EKS nodes run in private subnets; no direct public exposure
- **Branch protection** - `main` requires PR review; no direct pushes
- **Secrets scanning** - GitHub secret scanning and push protection are active

---

## Scope

This policy covers:
- `pipelineguard-infra` (this repo)
- [`pipelineguard-app`](https://github.com/sitardaniel/pipelineguard-app)
- [`pipelineguard-gitops`](https://github.com/sitardaniel/pipelineguard-gitops)
