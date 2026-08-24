# Live root template

Boilerplate template for scaffolding a live **`root.hcl`** — the shared Terragrunt configuration for providers, catalog, and remote state. This template also generates **`config/`** (via the [config template](../config/) dependency) because `root.hcl` reads those files at parse time.

Use this template when **starting a new live environment**. Developers joining an existing project with `root.hcl` already committed should scaffold the [config template](../config/) only.

Bootstrap infrastructure (folder, common project, state bucket) is **not** generated here — scaffold those from the catalog after `root.hcl` exists. See [Phase 1 — scaffold bootstrap units](#2-scaffold-bootstrap-units).

## The remote-state chicken-and-egg

Ideally, Terragrunt state lives in a **GCS bucket** created by the same IaC project. But `root.hcl` must exist before you can apply anything — including the bucket.

This template solves that with a **two-phase bootstrap**:

| Phase | `StateBucket` | State backend | What gets generated |
|-------|---------------|---------------|---------------------|
| **1 — bootstrap** | *(empty)* | Local state | `root.hcl` + `config/` |
| **2 — production** | bucket name | GCS remote state | `root.hcl` + `config/` (re-scaffold after bootstrap resources exist) |

```
Phase 1 (no StateBucket)        Phase 2 (StateBucket set)
────────────────────────        ──────────────────────────
scaffold root                   re-scaffold root
    ↓                               ↓
root.hcl (local state)          root.hcl (GCS backend)
config/                         config/
    ↓                               ↓
terragrunt catalog                  migrate state per unit
(folder + project units)              ↓
    ↓                           remote state in bucket
terragrunt plan / apply
    ↓
folder + project + bucket
```

## What it generates

```
root.hcl          # providers, catalog block, remote_state when StateBucket is set
config/           # from config template dependency (see config/README.md)
```

When **`StateBucket` is empty**, `root.hcl` omits the `remote_state` block so bootstrap units can use **local state** until the GCS bucket exists.

When **`StateBucket` is set**, `root.hcl` configures **GCS remote state** pointing at that bucket.

## Prerequisites

1. An empty live directory (for example `iac/live/` or `iac/gcp/live/`).
2. [mise](https://mise.jdx.dev/) for reproducible tool versions. From the catalog repository root:

```bash
mise install    # installs Terragrunt, OpenTofu, and other pinned tools
```

See [CONTRIBUTING.md](https://github.com/Nerdeez/terragrunt-catalog/blob/main/CONTRIBUTING.md) for full mise setup.
3. [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated:

```bash
gcloud auth login
gcloud auth application-default login
```

## Scaffold

No `catalog {}` block is required — pass the catalog repo URL on the CLI, or use `terragrunt scaffold` with the template git URL.

### Catalog TUI

```bash
cd iac/live   # or iac/gcp/live

terragrunt catalog github.com/Nerdeez/terragrunt-catalog
```

Select **Live root template**, press `s`, and scaffold into the live directory.

### Scaffold directly

```bash
cd iac/live   # or iac/gcp/live

terragrunt scaffold \
  'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/root?ref=<version>' \
  --output-folder .
```

Pin `ref` to a catalog release tag. Quote the URL in zsh — `?` is a glob character.

### From a local checkout of this catalog

```bash
cd iac/gcp/live

terragrunt scaffold ../catalog/templates/root --output-folder .
```

## Template variables

The root template declares its own variables and depends on the [config template](../config/) for org/billing/region values. All prompts appear in one scaffold session.

### Root-specific variables

| Variable | Type | When required | Description |
|----------|------|---------------|-------------|
| `StateBucket` | `string` | no | GCS bucket for remote state. Leave empty (phase 1) for local state. Set after bootstrap (phase 2). |

The generated `root.hcl` includes a fixed `catalog {}` block pointing at `github.com/Nerdeez/terragrunt-catalog` — not prompted during scaffold.

### Config variables (from dependency)

Passed through to the config template — see [config/README.md](../config/README.md) for descriptions and `gcloud` lookup commands:

| Variable | Written to |
|----------|------------|
| `OrgId` | `config/common.hcl` → `org_id` |
| `CommonProject` | `config/common.hcl` → `common_project` |
| `CustomerId` | `config/common.hcl` → `customer_id` |
| `BillingAccount` | `config/billing.hcl` → `billing_account` |
| `BillingProject` | `config/billing.hcl` → `billing_project` |
| `Region` | `config/region.hcl` → `region` |

## Phase 1 — bootstrap with local state

### 1. Scaffold root

```bash
terragrunt scaffold \
  'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/root?ref=<version>' \
  --output-folder .
```

Leave **`StateBucket` empty** when prompted (press Enter to accept the default). Fill in the config prompts (`OrgId`, `CommonProject`, etc.) when asked.

### 2. Scaffold bootstrap units

With `root.hcl` in place, use the catalog to scaffold the folder and project units. See [`units/folder/README.md`](../units/folder/README.md) and [`units/project/README.md`](../units/project/README.md) for unit-specific values and wiring.

```bash
terragrunt catalog
```

Scaffold into these paths:

| Unit | Output path | Notes |
|------|-------------|-------|
| **GCP Folder** | `common/folders/root` | Set `parent` to `organizations/<org_id>` and `names` to your top-level folder name. |
| **GCP Project** | `common/project` | Wire `folder_id` from the folder dependency. Set `bucket_name` to your state bucket (for example `my-org-live-tf-state`). Enable `storage.googleapis.com` in `activate_apis`. |

The live reference layout is under [`iac/gcp/live/common/`](../../../live/common/).

### 3. Review and apply

```bash
cd common/folders/root
terragrunt plan
terragrunt apply

cd ../../project
terragrunt plan
terragrunt apply
```

Note the **state bucket name** from the project unit — you will pass it as `StateBucket` in phase 2.

## Phase 2 — switch to remote state

### 1. Re-scaffold root with remote state

```bash
cd <live-directory>   # parent of root.hcl

terragrunt scaffold \
  'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/root?ref=<version>' \
  --output-folder . \
  --var StateBucket=my-org-live-tf-state
```

Use the bucket name created in phase 1.

Config prompts appear again (use the same values as phase 1).

### 2. Migrate state to the bucket

For each bootstrap unit applied in phase 1, re-initialize Terragrunt so local state is copied to GCS:

```bash
cd common/folders/root
terragrunt init -migrate-state

cd ../../project
terragrunt init -migrate-state
```

Confirm the migration prompt. Repeat for any other units created during bootstrap.

### 3. Verify

```bash
cd common/project
terragrunt plan   # should show no changes if migration succeeded
```

## After bootstrap

1. Commit `root.hcl`, `config/README.md`, and `config/*.example.hcl`.
2. Keep gitignored `config/*.hcl` local.
3. Run `terragrunt catalog` to scaffold additional infrastructure units.

## Relationship to the config template

The root template declares the config template as a Boilerplate dependency. It is fetched from the same git repo at the scaffold `Ref` (defaults to `main`) — Terragrunt only extracts `templates/root` to a temp dir when scaffolding from catalog, so a relative `../config` path is not available.

```yaml
# templates/root/.boilerplate/boilerplate.yml
dependencies:
  - name: config
    template-url: 'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/config/.boilerplate?ref={{ default "main" (index . "Ref") }}'
    output-folder: .
```

Config variables are gathered once and passed through. The root template renders `root.hcl` after `config/` exists.

## Template layout (catalog repository)

```
iac/gcp/catalog/templates/root/
├── README.md                 # this file
└── .boilerplate/
    ├── boilerplate.yml       # variables, config dependency (git URL)
    └── root.hcl              # Go template
```

## Related

- Bootstrap overview: [`templates/README.md`](../README.md)
- Config template: [`templates/config/README.md`](../config/README.md)
- Catalog units: [`units/`](../units/)
- Live reference: [`iac/gcp/live/root.hcl`](../../../live/root.hcl)
