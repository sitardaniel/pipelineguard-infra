## Summary

<!-- What infrastructure change does this PR make? -->

## Type of Change

- [ ] New module
- [ ] Module update
- [ ] Variable / output change
- [ ] Terragrunt config change
- [ ] Documentation
- [ ] Security fix

## Terraform Plan Output

<!-- Paste the relevant section of `terragrunt run-all plan` output -->

```
paste plan output here
```

## Security Checklist

- [ ] No AWS credentials, access keys, or secrets added to any file
- [ ] No `.tfstate` or `.terraform/` files included
- [ ] `terraform.tfvars` is not committed (use `.auto.tfvars.example` pattern)
- [ ] IAM permissions follow least-privilege
- [ ] Checkov scan passed locally (`checkov -d .`)
- [ ] Resources will be destroyed after demo (`terragrunt run-all destroy` confirmed)

## Cost Impact

<!-- Estimated cost of this change per demo session -->

Estimated cost: $

## Related Issues

Closes #
