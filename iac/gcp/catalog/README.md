# GCP infrastructure catalog

Reusable Terragrunt **units** and **stacks** for Google Cloud, following the [Terragrunt infrastructure catalog example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) layout.

Requires **Terragrunt 1.1+** and OpenTofu (or Terraform).

## Layout

| Path | Purpose |
|------|---------|
| [`units/`](units/) | Terragrunt units (folder, project, IAM bindings, groups, …) |
| [`stacks/`](stacks/) | Terragrunt stacks (e.g. full environment = folder + project) |
| [`modules/`](modules/) | Optional OpenTofu modules (add as needed) |

Each unit’s `terragrunt.hcl` includes live `root.hcl` via `find_in_parent_folders("root.hcl")`. Consumers must provide `root.hcl` (providers, remote state, impersonation) in their **live** repo.

## Consumption from live

`iac/gcp/live/root.hcl` registers this catalog:

```hcl
catalog {
  urls = [
    "${get_repo_root()}/iac/gcp/catalog",
  ]
}
```

Forks or other machines can use a Git URL instead:

```hcl
catalog {
  urls = [
    "git::git@github.com:ywarezk/academeez-k8s-flux.git//iac/gcp/catalog?ref=main",
  ]
}
```

### Catalog TUI

```bash
mkdir -p iac/gcp/live/experiments/my-unit
cd iac/gcp/live/experiments/my-unit
mise exec -- terragrunt catalog
```

Search with `/`, select a component, press **`s`** to scaffold into the current directory.

### Scaffold CLI

```bash
cd iac/gcp/live/experiments/my-folder
mise exec -- terragrunt scaffold "$(git rev-parse --show-toplevel)/iac/gcp/catalog/units/folder"
```

Or from Git (pinned ref):

```bash
mise exec -- terragrunt scaffold 'git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/folder?ref=main'
```

### Stacks

Reference a stack from live `terragrunt.stack.hcl` (see [`stacks/env/README.md`](stacks/env/README.md)).

### Hand-written live units

Do **not** `include` catalog `terragrunt.hcl` from live if live already `include`s `root.hcl` (nested includes). Use `include "root"` plus the same `terraform { source = ... }` as the catalog unit, or scaffold/copy the catalog unit as the entrypoint.

## Discovery

Component metadata lives in each unit/stack `README.md` (YAML frontmatter). `.terragrunt-catalog-ignore` excludes paths that are not catalog components.
