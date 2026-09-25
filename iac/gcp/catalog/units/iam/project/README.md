<!-- Frontmatter
name: GCP Project IAM
description: Manage IAM role bindings on Google Cloud projects.
tags:
  - unit
  - gcp
  - google
  - iam
  - project
-->

# GCP Project IAM

Manages IAM bindings on one or more Google Cloud projects.

This is a **Unit** component. It wraps the [terraform-google-modules/iam/google//modules/projects_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/projects_iam) submodule (v8.3.0).

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

All module inputs are optional in Terraform (each has a default). Set `projects` and `bindings` for real IAM changes.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `projects` | no | `[]` | Projects list to add the IAM policies/bindings. |
| `mode` | no | `"additive"` | Mode for adding IAM policies/bindings (`additive` or `authoritative`). |
| `bindings` | no | `{}` | Map of role (key) and list of members (value). |
| `conditional_bindings` | no | `[]` | Conditional IAM bindings (role, title, description, expression, members). |

After scaffolding, wire the unit into your live repository and supply environment-specific configuration there.

## Consumption

```hcl
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "iam_project" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/iam/project?ref=v0.0.2"
}

dependency "iam_sa" {
  config_path = "../../../service-accounts/iam"
}

inputs = {
  projects = [include.root.locals.billing_project]
  mode     = "additive"
  bindings = {
    "roles/serviceusage.serviceUsageConsumer" = [
      "serviceAccount:${dependency.iam_sa.outputs.email}"
    ]
  }
}
```

## Optional inputs

All inputs match the [projects_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/projects_iam?tab=inputs) submodule defaults:

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `projects` | `list(string)` | `[]` | Projects list to add the IAM policies/bindings. |
| `mode` | `string` | `"additive"` | Mode for adding the IAM policies/bindings, `additive` and `authoritative`. |
| `bindings` | `map(list(string))` | `{}` | Map of role (key) and list of members (value) to add the IAM policies/bindings. |
| `conditional_bindings` | `list(object)` | `[]` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings. |

## Commonly set in live

| Input | Notes |
|-------|--------|
| `projects` | Often `[include.root.locals.billing_project]` or another project ID from live config / `dependency`. |
| `bindings` | Role → member map; members use `user:`, `group:`, or `serviceAccount:` prefixes. |
| `mode` | `additive` is typical when extending existing project IAM. |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/projects_iam?tab=inputs) for the full list.
