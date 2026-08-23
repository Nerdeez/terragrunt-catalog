# Live config template

Boilerplate template for the **live** `config/` folder used by `root.hcl`. This is not a deployable Terragrunt unit — it scaffolds the `config/` directory in your live repository.

This template is a **dependency of the root template** ([`templates/root/`](../root/)). The root template declares it in `boilerplate.yml` so scaffolding `root.hcl` also generates `config/` in one step. You can also scaffold this template on its own — for example when joining an existing project and generating local `*.hcl` files from committed examples.

## What it generates

Running the template creates a `config/` directory next to your `root.hcl`:

```
config/
├── README.md              # developer instructions (scaffold command, gcloud hints)
├── billing.example.hcl    # committed placeholder — documents expected shape
├── common.example.hcl
├── region.example.hcl
├── billing.hcl            # your values (gitignored, created by scaffold)
├── common.hcl
├── region.hcl
└── .gitignore             # ignores the three *.hcl files above
```

**Committed files** (`README.md`, `*.example.hcl`) are safe to share in git — they help new developers understand what config is needed without exposing real org values.

**Gitignored files** (`*.hcl` without `.example`) hold your actual values and are written by the scaffold prompts.

`root.hcl` loads the gitignored files:

```hcl
region_config  = read_terragrunt_config(find_in_parent_folders("config/region.hcl")).locals
billing_config = read_terragrunt_config(find_in_parent_folders("config/billing.hcl")).locals
common_config  = read_terragrunt_config(find_in_parent_folders("config/common.hcl")).locals
```

The generated `config/.gitignore` keeps secrets and org-specific values out of version control. It is copied from the template as `%2Egitignore` (Boilerplate URL-decodes the path to `.gitignore` in the live output). The catalog repo does not store a literal `.gitignore` beside the template `*.hcl` files, so those sources stay tracked without negation rules. If your live repo already ignores `config/*.hcl` in a parent `.gitignore`, both approaches work.

A developer cloning a shared live repo sees the example files and `config/README.md` with the scaffold command, then generates their own local `*.hcl` files.

## When to use this template

| Scenario | What to run |
|----------|-------------|
| **New live environment** (no `root.hcl` yet) | Scaffold the [**root** template](../root/) — it depends on this config template and runs both |
| **Shared repo** (examples committed, local `*.hcl` missing) | Scaffold this config template directly |
| **Regenerate config only** | Scaffold this config template directly |

> No `catalog {}` block is required — pass the catalog repo URL on the CLI, or use `terragrunt scaffold` with the template git URL. The `catalog {}` block is written into the generated `root.hcl`.

## Prerequisites

1. A live folder (for example `iac/live/` or `iac/gcp/live/`). `root.hcl` is not required when scaffolding config on its own.
2. [Terragrunt](https://terragrunt.gruntwork.io/) installed (this catalog uses Terragrunt 1.1+).
3. [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated:

```bash
gcloud auth login
gcloud auth application-default login
```

## Scaffold

From your **live** directory (the folder that contains or will contain `root.hcl`):

### Catalog TUI

```bash
cd iac/live   # or iac/gcp/live

terragrunt catalog github.com/Nerdeez/terragrunt-catalog
```

Select **Live config template**, press `s`, and scaffold into the live directory. No `catalog {}` block is required when the repo URL is passed on the CLI.

### Scaffold directly

#### From the catalog git repository

```bash
cd iac/live   # or iac/gcp/live

terragrunt scaffold \
  'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/config?ref=<version>' \
  --output-folder .
```

Pin `ref` to a catalog release tag (for example `v1.1.0`). Quote the URL in zsh — `?` is a glob character.

#### From a local checkout of this catalog

```bash
cd iac/gcp/live

terragrunt scaffold ../catalog/templates/config --output-folder .
```

Terragrunt uses the `.boilerplate/` folder inside `templates/config/` and prompts for each input variable. You can also pass values non-interactively:

```bash
terragrunt scaffold ../catalog/templates/config \
  --output-folder . \
  --var OrgId=123456789 \
  --var CommonProject=my-common-project \
  --var CustomerId=C01234567 \
  --var BillingAccount=012345-6789AB-CDEF01 \
  --var BillingProject=my-common-project \
  --var Region=us-central1
```

## Configuration variables

Each prompt maps to a value in the generated `config/*.hcl` files. Use the `gcloud` commands below to look up values before scaffolding (the same hints appear in the interactive prompts).

| Variable | Written to | Description | How to find the value |
|----------|------------|-------------|------------------------|
| `OrgId` | `common.hcl` → `org_id` | GCP organization numeric ID | `gcloud organizations list --format='table(displayName,name)'` — use the number from `organizations/123456789` |
| `CommonProject` | `common.hcl` → `common_project` | Shared project ID (remote state bucket, shared APIs) | `gcloud projects list --format='table(projectId,name)'` |
| `CustomerId` | `common.hcl` → `customer_id` | Google Workspace / Cloud Identity customer ID | `gcloud organizations list --format='table(displayName,directoryCustomerId)'` — column `directoryCustomerId` (for example `C01234567`) |
| `BillingAccount` | `billing.hcl` → `billing_account` | Billing account ID (`XXXXXX-XXXXXX-XXXXXX`) | `gcloud billing accounts list --format='table(name,displayName,open)'` — use the ID after `billingAccounts/` |
| `BillingProject` | `billing.hcl` → `billing_project` | Project used for billing API quota in provider config | Usually the same as `common_project`; confirm with `gcloud projects list --format='table(projectId,name)'` |
| `Region` | `region.hcl` → `region` | Default GCP region for providers and resources | `gcloud compute regions list --format='table(name,status)'` — default: `us-central1` |

### Example: collect all values in one pass

```bash
# Organization and Workspace customer ID
gcloud organizations list \
  --format='table(displayName,name,directoryCustomerId)'

# Projects
gcloud projects list \
  --format='table(projectId,name)'

# Billing accounts
gcloud billing accounts list \
  --format='table(name,displayName,open)'

# Regions
gcloud compute regions list \
  --format='table(name,status)'
```

## Generated file reference

### `config/common.hcl`

```hcl
locals {
  org_id         = "<OrgId>"
  common_project = "<CommonProject>"
  customer_id    = "<CustomerId>"
}
```

Used by `root.hcl` for remote state (`common_project`), provider defaults, and catalog units that need `org_id` or `customer_id` (for example Google Workspace groups).

### `config/billing.hcl`

```hcl
locals {
  billing_account = "<BillingAccount>"
  billing_project = "<BillingProject>"
}
```

Used by `root.hcl` for `billing_project` and `billing_account` in provider configuration.

### `config/region.hcl`

```hcl
locals {
  region = "<Region>"
}
```

Used by `root.hcl` for the default `region` in `google` and `google-beta` providers.

## After scaffolding

1. Confirm `config/README.md` and the three `*.example.hcl` files are present (safe to commit).
2. Confirm the three gitignored `config/*.hcl` files exist and contain the expected values.
3. Run any Terragrunt command from a child unit to verify `root.hcl` reads config correctly:

```bash
terragrunt validate --terragrunt-working-dir <any-unit>
```

4. Continue with catalog units: `terragrunt catalog` from your live directory.

## Template layout (catalog repository)

```
iac/gcp/catalog/templates/config/
├── README.md                 # this file (catalog maintainer docs)
└── .boilerplate/
    ├── boilerplate.yml       # input variables and prompts
    └── config/
        ├── README.md         # copied to live — developer-facing instructions
        ├── billing.example.hcl   # static, committed to live
        ├── common.example.hcl
        ├── region.example.hcl
        ├── billing.hcl       # Go template → gitignored live file
        ├── common.hcl
        ├── region.hcl
        └── %2Egitignore      # URL-encoded — outputs as config/.gitignore in live
```

## Relationship to the root template

The root template (`templates/root`) will declare this template as a Boilerplate dependency:

```yaml
# templates/root/.boilerplate/boilerplate.yml
dependencies:
  - name: config
    template-url: '{{ replace templateURL "templates/root" "templates/config/.boilerplate" }}'
    output-folder: .
```

Config variables (`OrgId`, `CommonProject`, etc.) are gathered once and passed through to the config dependency. The root template then renders `root.hcl` (including the `catalog {}` block) after `config/` exists.

## Related

- Bootstrap overview: [`templates/README.md`](../README.md)
- Live config (course reference): [`iac/gcp/live/config/`](../../../live/config/)
- Catalog units (infrastructure scaffolding): [`iac/gcp/catalog/units/`](../units/)
