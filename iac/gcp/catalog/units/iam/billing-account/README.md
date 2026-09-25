<!-- Frontmatter
name: GCP Billing Account IAM
description: Manage IAM role bindings on Google Cloud billing accounts.
tags:
  - unit
  - gcp
  - google
  - iam
  - billing
-->

# GCP Billing Account IAM

Manages IAM bindings on one or more Google Cloud billing accounts.

This is a **Unit** component. It wraps the [terraform-google-modules/iam/google//modules/billing_accounts_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/billing_accounts_iam) submodule (v8.3.0).

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `bindings` | yes | — | Map of IAM role (key) to list of members (value). |
| `billing_account_ids` | no | `[]` | Billing account IDs to apply IAM bindings on (set at least one for real use). |
| `mode` | no | `"additive"` | `additive` merges bindings; `authoritative` replaces bindings for listed roles. |

After scaffolding, wire the unit into your live repository and supply environment-specific configuration there.

## Consumption

```hcl
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "iam_billing_account" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/iam/billing-account?ref=v0.0.2"
}

dependency "iam_sa" {
  config_path = "../../../service-accounts/iam"
}

inputs = {
  billing_account_ids = [include.root.locals.billing_account]
  mode                = "additive"
  bindings = {
    "roles/billing.admin" = [
      "serviceAccount:${dependency.iam_sa.outputs.email}"
    ]
  }
}
```

Billing account IDs belong in the **live** repository (`root.hcl` from `config/billing.hcl`).

## Required inputs

| Input | Type | Description |
|-------|------|-------------|
| `bindings` | `map(list(string))` | Map of role (key) and list of members (value) to add the IAM policies/bindings. |

## Optional inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `billing_account_ids` | `list(string)` | `[]` | Billing Accounts IDs list to add the IAM policies/bindings. |
| `mode` | `string` | `"additive"` | Mode for adding the IAM policies/bindings, `additive` and `authoritative`. |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/billing_accounts_iam?tab=inputs) for the full list.
