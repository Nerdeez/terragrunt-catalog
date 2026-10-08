<!-- Frontmatter
name: GCP Artifact Registry
description: Create a repository in GAR
tags:
  - unit
  - gcp
  - google
  - gar
-->

# GCP Artifact Registry

Creates a single **Artifact Registry** repository (Docker by default) for storing container images or other packages.

This is a **Unit** component. It wraps the [GoogleCloudPlatform/artifact-registry/google](https://registry.terraform.io/modules/GoogleCloudPlatform/artifact-registry/google/latest) module. The pinned module version lives only in [`terragrunt.hcl`](./terragrunt.hcl) (`terraform.source`).

The project must have the `artifactregistry.googleapis.com` API enabled (see the [project unit](../project/README.md) `activate_apis`).

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold. Terragrunt prompts for each `values.*` reference (`x` keeps the `try()` default).

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `project_id` | yes | — | Project that hosts the repository. |
| `repository_id` | yes | — | Repository name (for example `demo-apps`). Images are addressed as `<location>-docker.pkg.dev/<project_id>/<repository_id>/<image>`. |
| `location` | no | `us-central1` | Region or multi-region (`us`, `europe`, `asia`). Use the GKE region to keep pulls in-region. |
| `format` | no | `DOCKER` | Package format: `DOCKER`, `MAVEN`, `NPM`, `PYTHON`, `APT`, `YUM`, `GO`. |
| `mode` | no | `STANDARD_REPOSITORY` | `STANDARD_REPOSITORY`, `REMOTE_REPOSITORY` (pull-through cache), or `VIRTUAL_REPOSITORY`. |
| `description` | no | `null` | Repository description. |
| `labels` | no | `{}` | Repository labels. |
| `docker_config` | no | `null` | Docker settings, e.g. `{ immutable_tags = true }`. |
| `cleanup_policies` | no | `{}` | Map of cleanup policy ID to policy (delete old or untagged versions, keep the most recent N). |
| `cleanup_policy_dry_run` | no | `false` | Evaluate cleanup policies without deleting anything. |
| `members` | no | `{}` | Repository-level IAM: `{ readers = [...], writers = [...] }` with IAM-style members. |
| `kms_key_name` | no | `null` | CMEK key; cannot be changed after creation. |
| `remote_repository_config` | no | `null` | Upstream config when `mode = "REMOTE_REPOSITORY"`. |
| `virtual_repository_config` | no | `null` | Upstream policies when `mode = "VIRTUAL_REPOSITORY"`. |

## Consumption

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "artifact_registry" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/artifact-registry?ref=<version>"
}

dependency "project" {
  config_path = "../project"
}

inputs = merge(
  {
    repository_id = "demo-apps"
    location      = "us-central1"
  },
  {
    project_id = dependency.project.outputs.project_id
  },
)
```

### GKE image pulls

GKE nodes need `roles/artifactregistry.reader`. With the [GKE unit](../gke/README.md) default `grant_registry_access = true`, the node service account already has read access to repositories in the cluster project, so `members` can stay empty. Grant `readers` here only when nodes run in a **different** project.

### CI pushes

Grant push access to a CI service account at repository scope:

```hcl
inputs = {
  members = {
    writers = ["serviceAccount:ci@<project_id>.iam.gserviceaccount.com"]
  }
}
```

### Cleanup policy (keep the 10 most recent versions)

```hcl
inputs = {
  cleanup_policies = {
    "keep-recent" = {
      action = "KEEP"
      most_recent_versions = {
        keep_count = 10
      }
    }
    "delete-untagged" = {
      action = "DELETE"
      condition = {
        tag_state  = "UNTAGGED"
        older_than = "604800s"
      }
    }
  }
}
```

## Required inputs (module)

| Input | Type | Description |
|-------|------|-------------|
| `project_id` | `string` | Project ID (catalog: `values.project_id`). |
| `repository_id` | `string` | Repository name. |
| `location` | `string` | Repository location. |
| `format` | `string` | Package format. |

See the [module inputs](https://registry.terraform.io/modules/GoogleCloudPlatform/artifact-registry/google/latest?tab=inputs) for full details.

## Outputs

| Output | Description |
|--------|-------------|
| `artifact_id` | Repository ID (`projects/<project>/locations/<location>/repositories/<repository_id>`). |
| `artifact_name` | Repository name. |
| `create_time` | Creation timestamp. |
| `update_time` | Last update timestamp. |

See the [module outputs](https://registry.terraform.io/modules/GoogleCloudPlatform/artifact-registry/google/latest?tab=outputs) for the full list.
