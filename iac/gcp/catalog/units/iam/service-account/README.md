<!-- Frontmatter
name: GCP Service Account IAM
description: Manage IAM role bindings on Google Cloud service accounts.
tags:
  - unit
  - gcp
  - google
  - iam
  - service-account
-->

# GCP Service Account IAM

Manages IAM bindings on service accounts within a project.

This is a **Unit** component. It wraps the [terraform-google-modules/iam/google//modules/service_accounts_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/service_accounts_iam) submodule (v8.3.0).

> **Note:** This unit grants IAM **on** service accounts. To **create** service accounts, use the [`service-account`](../../service-account/) catalog unit.

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

All module inputs are optional in Terraform (each has a default). Set `project`, `service_accounts`, and `bindings` for real IAM changes.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `project` | no | `""` | Project to add the IAM policies/bindings. |
| `service_accounts` | no | `[]` | Service account emails to add the IAM policies/bindings. |
| `mode` | no | `"additive"` | Mode for adding IAM policies/bindings (`additive` or `authoritative`). |
| `bindings` | no | `{}` | Map of role (key) and list of members (value). |
| `conditional_bindings` | no | `[]` | Conditional IAM bindings (role, title, description, expression, members). |

After scaffolding, wire the unit into your live repository and supply environment-specific configuration there.

## Consumption

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "iam_service_account" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/iam/service-account?ref=v0.0.2"
}

dependency "iam_sa" {
  config_path = "../../../service-accounts/iam"
}

dependency "admin_group" {
  config_path = "../../../groups/admin"
}

dependency "project" {
  config_path = "../../../project"
}

inputs = {
  service_accounts = [dependency.iam_sa.outputs.email]
  project          = dependency.project.outputs.project_id
  mode             = "authoritative"
  bindings = {
    "roles/iam.serviceAccountTokenCreator" = [
      "group:${dependency.admin_group.outputs.id}"
    ]
  }
}
```

## Optional inputs

All inputs match the [service_accounts_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/service_accounts_iam?tab=inputs) submodule defaults:

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `project` | `string` | `""` | Project to add the IAM policies/bindings. |
| `service_accounts` | `list(string)` | `[]` | Service Accounts Email list to add the IAM policies/bindings. |
| `mode` | `string` | `"additive"` | Mode for adding the IAM policies/bindings, `additive` and `authoritative`. |
| `bindings` | `map(list(string))` | `{}` | Map of role (key) and list of members (value) to add the IAM policies/bindings. |
| `conditional_bindings` | `list(object)` | `[]` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings. |

## Commonly set in live

| Input | Notes |
|-------|--------|
| `project` | Project ID that owns the service accounts (often from a `dependency` on the IAM project unit). |
| `service_accounts` | List of service account emails (often `[dependency.<sa>.outputs.email]`). |
| `bindings` | Typical roles include `roles/iam.serviceAccountTokenCreator` for impersonation. |
| `mode` | Often `authoritative` when the live stack should own the binding set for listed roles. |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/service_accounts_iam?tab=inputs) for the full list.
