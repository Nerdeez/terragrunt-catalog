<!-- Frontmatter
name: GCP Storage Bucket IAM
description: Manage IAM role bindings on Google Cloud Storage buckets.
tags:
  - unit
  - gcp
  - google
  - iam
  - storage
-->

# GCP Storage Bucket IAM

Manages IAM bindings on one or more Google Cloud Storage buckets.

This is a **Unit** component. It wraps the [terraform-google-modules/iam/google//modules/storage_buckets_iam](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/storage_buckets_iam) submodule (v8.3.0).

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `bindings` | yes | — | Map of role (key) and list of members (value). |
| `storage_buckets` | no | `[]` | Storage bucket names to add the IAM policies/bindings. |
| `mode` | no | `"additive"` | Mode for adding IAM policies/bindings (`additive` or `authoritative`). |
| `conditional_bindings` | no | `[]` | Conditional IAM bindings (role, title, description, expression, members). |

Set `storage_buckets` together with `bindings` for real IAM changes.

After scaffolding, wire the unit into your live repository and supply environment-specific configuration there.

## Consumption

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "iam_storage_bucket" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/iam/storage-bucket?ref=v0.0.2"
}

dependency "operators_group" {
  config_path = "../../../groups/terragrunt"
}

inputs = {
  storage_buckets = ["my-terragrunt-state-bucket"]
  mode            = "additive"
  bindings = {
    "roles/storage.admin" = [
      "group:${dependency.operators_group.outputs.id}"
    ]
  }
}
```

## Required inputs

| Input | Type | Description |
|-------|------|-------------|
| `bindings` | `map(list(string))` | Map of role (key) and list of members (value) to add the IAM policies/bindings. |

In [storage_buckets_iam v6.2.0](https://registry.terraform.io/modules/terraform-google-modules/iam/google/6.2.0/submodules/storage_buckets_iam), `bindings` has no default. The catalog unit always prompts for it. (v8.3.0 adds a `{}` default in Terraform; empty bindings still do nothing useful.)

## Optional inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `storage_buckets` | `list(string)` | `[]` | Storage Buckets list to add the IAM policies/bindings. |
| `mode` | `string` | `"additive"` | Mode for adding the IAM policies/bindings, `additive` and `authoritative`. |
| `conditional_bindings` | `list(object)` | `[]` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings. |

## Commonly set in live

| Input | Notes |
|-------|--------|
| `storage_buckets` | Bucket names (e.g. Terragrunt state bucket). |
| `bindings` | Often `roles/storage.admin` for an operators group. |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/iam/google/8.3.0/submodules/storage_buckets_iam?tab=inputs) for the full list.
