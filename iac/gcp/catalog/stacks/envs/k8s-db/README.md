<!-- Frontmatter
name: K8s + DB environment
description: Catalog stack for a GCP environment folder and project (foundation for GKE and data plane).
tags:
  - stack
  - gcp
  - environment
  - k8s
-->

# K8s + DB environment stack

Reusable **catalog stack** that provisions the GCP foundation for an environment (for example `prod` or `non-prod`): a folder under a parent folder and a billing-linked project inside that folder.

Managed Kubernetes, networking, and database units will be added to this stack in later changes. Today it only materializes the **folder** and **project** units.

## Generated layout

Each live `stack` instance copies units under its `path`:

```text
<stack-path>/
  folder/   # catalog/units/folder
  project/  # catalog/units/project (depends on folder)
```

## Required `values`

| Value | Description |
|-------|-------------|
| `name` | Environment name used for the folder display name and project `name` (for example `prod`, `non-prod`). |
| `billing_account` | GCP billing account ID attached to the environment project. |
| `parent_folder_config_path` | Terragrunt config path to the **parent folder** unit (dependency). Its `id` output becomes the new folder’s `parent`. |

## Optional overrides

| Value | Description |
|-------|-------------|
| `folder_inputs` | Extra inputs for the folder unit, merged over [folder defaults](#folder-defaults). |
| `project_inputs` | Extra inputs for the project unit, merged over [project defaults](#project-defaults). |

Input merge order inside each unit (later keys win):

1. Stack `locals` defaults (`folder_defaults` / `project_defaults`)
2. `folder_inputs` or `project_inputs` from the caller
3. Wired fields (`parent`, `names`, `folder_id`, `name`, `billing_account`)

See [catalog units README](../../units/README.md) for how `values.*` and `autoinclude` interact with unit `inputs`.

## Stack defaults

Only settings that **differ** from the catalog unit `try()` fallbacks are set here. Everything else uses [units/folder](../../units/folder/README.md) and [units/project](../../units/project/README.md) defaults.

### Folder defaults

`folder_defaults` is empty. Optional folder behavior (for example `deletion_protection`) uses the folder unit defaults unless you pass `folder_inputs`.

### Project defaults

| Input | Value | Notes |
|-------|-------|--------|
| `random_project_id` | `true` | Unit default is `false`; environments use a random suffix for a globally unique `project_id`. |
| `create_project_sa` | `false` | Unit default is `true`; do not create the optional project-factory service account. |

The Google-managed **default compute service account** is handled by `default_service_account` on the project unit (default `"disable"` — not overridden here). GCP may still create that account when APIs such as Compute are enabled; project-factory then disables it (or use `project_inputs` with `"delete"` / `"deprivilege"` if you need stronger handling).

`folder_id`, `name`, and `billing_account` are always supplied by the stack wiring, not by defaults.

## Consumption

Instantiate from a live `terragrunt.stack.hcl` with one `stack` block per environment:

```hcl
locals {
  billing_config  = read_terragrunt_config(find_in_parent_folders("config/billing.hcl")).locals
  billing_account = local.billing_config.billing_account
}

stack "prod" {
  source = "${get_repo_root()}/iac/gcp/catalog/stacks/envs/k8s-db"
  path   = "prod"

  values = {
    name                      = "prod"
    billing_account           = local.billing_account
    parent_folder_config_path = "${get_repo_root()}/iac/gcp/live/common/folders/root"
  }
}
```

A full prod + non-prod example lives in [`iac/gcp/live/envs/terragrunt.stack.hcl`](../../../../live/envs/terragrunt.stack.hcl).

### Per-environment overrides

```hcl
stack "non-prod" {
  source = "${get_repo_root()}/iac/gcp/catalog/stacks/envs/k8s-db"
  path   = "non-prod"

  values = {
    name                      = "non-prod"
    billing_account           = local.billing_account
    parent_folder_config_path = "${get_repo_root()}/iac/gcp/live/common/folders/root"

    project_inputs = {
      # Example: expand APIs when adding GKE / Cloud SQL units to this stack
      # activate_apis = ["compute.googleapis.com", "container.googleapis.com"]
    }
  }
}
```

## Units used

| Unit | Catalog path | Dependency |
|------|----------------|------------|
| Folder | [`units/folder`](../../units/folder/README.md) | Parent folder at `parent_folder_config_path` |
| Project | [`units/project`](../../units/project/README.md) | Environment folder (`unit.folder`) |

## Roadmap

Planned additions on this stack (not implemented yet):

- VPC / subnets (private GKE, PSA for managed databases)
- GKE cluster
- PostgreSQL or other data-plane units under [`units/db`](../../units/db/postgresql/README.md)
