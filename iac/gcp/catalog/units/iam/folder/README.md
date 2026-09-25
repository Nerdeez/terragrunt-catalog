<!-- Frontmatter
name: GCP Folder IAM
description: Manage IAM role bindings on Google Cloud folders.
tags:
  - unit
  - gcp
  - google
  - iam
  - folder
-->

# GCP Folder IAM

Manages IAM bindings on one or more Google Cloud folders.

This is a **Unit** component. It wraps the [terraform-google-modules/iam/google//modules/folders_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/folders_iam) submodule (v8.3.0).

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

All module inputs are optional in Terraform (each has a default). Set `folders` and `bindings` for real IAM changes.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `folders` | no | `[]` | Folders list to add the IAM policies/bindings. |
| `mode` | no | `"additive"` | Mode for adding IAM policies/bindings (`additive` or `authoritative`). |
| `bindings` | no | `{}` | Map of role (key) and list of members (value). |
| `conditional_bindings` | no | `[]` | Conditional IAM bindings (role, title, description, expression, members). |

After scaffolding, wire the unit into your live repository and supply environment-specific configuration there.

## Consumption

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "iam_folder" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/iam/folder?ref=v0.0.2"
}

dependency "folder" {
  config_path = "../../../../common/folders/root"
}

dependency "iam_sa" {
  config_path = "../../../service-accounts/iam"
}

inputs = {
  folders = [dependency.folder.outputs.id]
  mode    = "authoritative"
  bindings = {
    "roles/resourcemanager.folderViewer" = [
      "serviceAccount:${dependency.iam_sa.outputs.email}"
    ]
  }
}
```

## Optional inputs

All inputs match the [folders_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/folders_iam?tab=inputs) submodule defaults:

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `folders` | `list(string)` | `[]` | Folders list to add the IAM policies/bindings. |
| `mode` | `string` | `"additive"` | Mode for adding the IAM policies/bindings, `additive` and `authoritative`. |
| `bindings` | `map(list(string))` | `{}` | Map of role (key) and list of members (value) to add the IAM policies/bindings. |
| `conditional_bindings` | `list(object)` | `[]` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings. |

## Commonly set in live

| Input | Notes |
|-------|--------|
| `folders` | Usually from a `dependency` on a folder unit (e.g. `dependency.folder.outputs.id`). |
| `bindings` | Role → member map; members use `user:`, `group:`, or `serviceAccount:` prefixes. |
| `mode` | Often `authoritative` when the live stack should own the full binding set for listed roles. |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/folders_iam?tab=inputs) for the full list.
