<!-- Frontmatter
name: Environment
description: Create an opinionated Kubernetes environment as a GCP folder with a project inside it.
tags:
  - stack
  - gcp
  - google
  - k8s
  - environment
-->

# Environment

Creates an opinionated Kubernetes environment on Google Cloud.

This is a **Stack** component. From a single `terragrunt.stack.hcl` file it generates a tree of units:

| Unit | Path | Purpose |
|------|------|---------|
| `folder` | `folder` | A GCP folder named after the environment, created under the supplied parent folder. |
| `project` | `project` | A GCP project created inside the environment folder. |

The `project` unit automatically depends on the `folder` unit and receives its `id` as `folder_id`, so the units are wired together for you.

Catalog units include live `root.hcl` via `find_in_parent_folders("root.hcl")` (see [Gruntwork catalog units](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example)). Consumers must provide `root.hcl` above scaffolded or stack-generated units.

## Scaffolding

From the catalog TUI, select this stack and press `s` to scaffold it into your working directory. Terragrunt copies the stack files in place and generates a `terragrunt.values.hcl` for the `values.*` references collected by the form.

After scaffolding, supply the required values in your **live** repository.

## Consumption

Reference the stack from a `terragrunt.stack.hcl` in your live repository and supply the required values:

```hcl
locals {
  billing         = read_terragrunt_config(find_in_parent_folders("config/billing.hcl")).locals
  billing_account = local.billing.billing_account
}

stack "non-prod-temp" {
  source = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/catalog/stacks/env?ref=v0.0.2"
  path   = "non-prod-temp"

  values = {
    name                      = "non-prod-temp"
    parent_folder_config_path = "${get_repo_root()}/iac/live/common/folders/root"
    billing_account           = local.billing_account
    project_inputs = {
      budget_amount     = 50
      random_project_id = true
    }
  }
}
```

Generate and inspect the units with:

```bash
terragrunt stack generate --experiment stack-dependencies
```

## Required values

| Value | Type | Description |
|-------|------|-------------|
| `name` | `string` | Name of the environment. Used as the folder name and the project name. |
| `parent_folder_config_path` | `string` | Path to the parent folder unit whose `id` output becomes this environment's parent folder. |
| `billing_account` | `string` | Billing account ID to attach to the environment's project. Required by the [project-factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest?tab=inputs). |

## Optional values

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| `folder_inputs` | `map(any)` | `{}` | Overrides catalog folder defaults (see below). See the [folder unit inputs](https://registry.terraform.io/modules/terraform-google-modules/folders/google/latest?tab=inputs). |
| `project_inputs` | `map(any)` | `{}` | Overrides catalog project defaults (see below). See the [project unit inputs](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest?tab=inputs). |

### Catalog defaults (overridable)

The stack merges inputs in this order (later wins):

1. **Catalog defaults** — opinionated baseline from the stack
2. **`folder_inputs` / `project_inputs`** — live-repo overrides
3. **Stack wiring** — `parent`, `names`, `folder_id`, `name`, `billing_account` (always set by the stack)

| Unit | Catalog default | Value |
|------|-----------------|-------|
| folder | `deletion_protection` | `false` |
| project | `random_project_id` | `true` |
| project | `deletion_policy` | `"DELETE"` |
| project | `create_project_sa` | `false` |
| project | `default_service_account` | `"disable"` |

To override a default, set the key in `folder_inputs` or `project_inputs` in your live `terragrunt.stack.hcl`. For example, `project_inputs = { deletion_policy = "PREVENT" }` keeps everything else and only changes that field.

The `parent_folder_config_path` must point at a unit that exposes an `id` output (for example the `folder` unit under `iac/live/common/folders/...`). The `folder` unit's `parent` input is wired to `dependency.parent_folder.outputs.id`, and a `mock_outputs` value is provided so `terragrunt stack generate` and `plan` work before the parent folder has been applied.
