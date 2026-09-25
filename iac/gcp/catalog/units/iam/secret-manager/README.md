<!-- Frontmatter
name: GCP Secret Manager IAM
description: Manage IAM role bindings on Google Cloud Secret Manager secrets.
tags:
  - unit
  - gcp
  - google
  - iam
  - secret-manager
-->

# GCP Secret Manager IAM

Manages IAM bindings on one or more Secret Manager secrets in a project.

This is a **Unit** component. It wraps the [terraform-google-modules/iam/google//modules/secret_manager_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/secret_manager_iam) submodule (v8.3.0).

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `bindings` | yes | — | Map of role (key) and list of members (value). |
| `project` | no | `""` | Project ID where the secrets live. |
| `secrets` | no | `[]` | Secret Manager secret IDs to add the IAM policies/bindings. |
| `mode` | no | `"additive"` | Mode for adding IAM policies/bindings (`additive` or `authoritative`). |
| `conditional_bindings` | no | `[]` | Conditional IAM bindings (role, title, description, expression, members). |

Set `project`, `secrets`, and `bindings` together for real IAM changes.

After scaffolding, wire the unit into your live repository and supply environment-specific configuration there.

## Consumption

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "iam_secret_manager" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/iam/secret-manager?ref=v0.0.2"
}

dependency "project" {
  config_path = "../../project"
}

dependency "workload_sa" {
  config_path = "../../service-accounts/workload"
}

inputs = {
  project = dependency.project.outputs.project_id
  secrets = ["app-db-password"]
  mode    = "additive"
  bindings = {
    "roles/secretmanager.secretAccessor" = [
      "serviceAccount:${dependency.workload_sa.outputs.email}"
    ]
  }
}
```

## Required inputs

| Input | Type | Description |
|-------|------|-------------|
| `bindings` | `map(list(string))` | Map of role (key) and list of members (value) to add the IAM policies/bindings. |

In [secret_manager_iam v8.3.0](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/secret_manager_iam?tab=inputs), `bindings` has no default. The catalog unit always prompts for it.

## Optional inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `project` | `string` | `""` | Project to add the IAM policies/bindings. |
| `secrets` | `list(string)` | `[]` | Secret Manager secret IDs to add the IAM policies/bindings. |
| `mode` | `string` | `"additive"` | Mode for adding the IAM policies/bindings, `additive` and `authoritative`. |
| `conditional_bindings` | `list(object)` | `[]` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings. |

## Commonly set in live

| Input | Notes |
|-------|--------|
| `project` | Usually from a `dependency` on a project unit (`dependency.project.outputs.project_id`). |
| `secrets` | Secret IDs (short names) of existing Secret Manager secrets in `project`. |
| `bindings` | Common roles: `roles/secretmanager.secretAccessor`, `roles/secretmanager.viewer`, `roles/secretmanager.admin`. |
| `mode` | Often `authoritative` when the live stack should own the full binding set for listed roles. |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/secret_manager_iam?tab=inputs) for the full list.
