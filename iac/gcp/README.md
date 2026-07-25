# Google Cloud Platform (GCP)

GCP infrastructure for the academeez IAC course.

## Structure

| Folder | Purpose |
|--------|---------|
| [`catalog/`](catalog/) | Reusable Terragrunt units and stacks ([catalog README](catalog/README.md)) |
| [`live/`](live/) | Live environment that consumes catalog units |

Register the catalog in `live/root.hcl`, then run `terragrunt catalog` or `terragrunt scaffold` from a directory under `live/`. Requires Terragrunt **1.1+** (`mise install`).

Start in [`live/config/`](live/config/) to copy example config files, then run Terragrunt from the relevant unit under `live/`.
