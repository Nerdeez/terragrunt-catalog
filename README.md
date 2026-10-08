# Terragrunt Catalog & Infrastructure as Code Course

A production-ready, multi-cloud **[Terragrunt catalog](https://terragrunt.gruntwork.io/docs/features/catalog/)**, paired with a free, hands-on **[Infrastructure as Code course](https://www.academeez.com/courses/terraform)** on Terraform, OpenTofu, and Terragrunt. The course currently covers **Google Cloud Platform**; additional cloud providers are planned.

Use the catalog as reusable building blocks in your own projects. Follow the course in the [`iac/gcp/live/`](iac/gcp/live/) folder to learn how every piece fits together.

> **Free & open source** — [academeez](https://www.academeez.com/) is MIT licensed. No registration, no clickbait. Quality programming education.

If this helps your work, **[give the repo a star](https://github.com/Nerdeez/terragrunt-catalog)** — it helps other developers find it.

---

## What is this repository?

This repo serves two purposes:

| | **Catalog** | **Live (course)** |
|---|---|---|
| **Location** | [`iac/gcp/catalog/`](iac/gcp/catalog/) | [`iac/gcp/live/`](iac/gcp/live/) |
| **Purpose** | Reusable Terragrunt units and stacks you can import into any GCP project | A working GCP environment built step-by-step through the course |
| **Use it when** | You want opinionated, battle-tested units for folders, projects, IAM, VPC, and more | You want to learn IaC best practices by following along with real infrastructure |

The **catalog** is like a library of infrastructure functions. The **live** folder is the course workbook — it consumes those catalog units to provision real cloud resources while teaching Terragrunt patterns along the way.

---

## Terragrunt Catalog

The catalog contains reusable **units** (single deployable pieces of infrastructure) and **stacks** (logical groups of units). Each unit wraps a well-known Terraform module (for example `terraform-google-modules/project-factory`) and exposes a clean `values.*` API for customization.

### Available units

| Unit | Description |
|------|-------------|
| [`folder`](iac/gcp/catalog/units/folder/) | GCP folder |
| [`project`](iac/gcp/catalog/units/project/) | GCP project |
| [`group`](iac/gcp/catalog/units/group/) | Google Workspace / Cloud Identity group |
| [`service-account`](iac/gcp/catalog/units/service-account/) | GCP service account |
| [`storage-bucket`](iac/gcp/catalog/units/storage-bucket/) | GCS bucket |
| [`artifact-registry`](iac/gcp/catalog/units/artifact-registry/) | Artifact Registry repository |
| [`vpc`](iac/gcp/catalog/units/vpc/) | VPC network |
| [`db/postgresql`](iac/gcp/catalog/units/db/postgresql/) | Cloud SQL PostgreSQL |
| [`iam/folder`](iac/gcp/catalog/units/iam/folder/) | IAM bindings on a folder |
| [`iam/project`](iac/gcp/catalog/units/iam/project/) | IAM bindings on a project |
| [`iam/service-account`](iac/gcp/catalog/units/iam/service-account/) | IAM bindings on a service account |
| [`iam/storage-bucket`](iac/gcp/catalog/units/iam/storage-bucket/) | IAM bindings on a storage bucket |
| [`iam/billing-account`](iac/gcp/catalog/units/iam/billing-account/) | IAM bindings on a billing account |

See [`iac/gcp/catalog/units/README.md`](iac/gcp/catalog/units/README.md) for details on the `values.*` pattern and partial configuration.

### Install the catalog in your project

Add a `catalog` block to your root Terragrunt configuration (for example `root.hcl`):

```hcl
catalog {
  urls = [
    "github.com/Nerdeez/terragrunt-catalog",
  ]
}
```

Then browse and scaffold units interactively:

```bash
cd your-live-repo
terragrunt catalog
```

From the catalog TUI you can explore available units and press `s` to scaffold a unit into your working directory. Terragrunt copies the unit files, prompts for each `values.*` reference, and writes a `terragrunt.values.hcl` with your answers.

You can also reference catalog units directly with `include`:

```hcl
include "project" {
  path = "git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/units/project?ref=<version>"
}
```

Pin to a specific tag (`?ref=v0.0.2`) so catalog updates do not break your live infrastructure.

### Catalog vs live

- **Catalog** — reusable templates. No org-specific values. Safe to share across teams and projects.
- **Live** — your actual infrastructure. Org IDs, billing accounts, group emails, and impersonation targets live here.

This separation is a core Terragrunt best practice covered in the course.

---

## Infrastructure as Code Course

The [`iac/gcp/live/`](iac/gcp/live/) folder is the hands-on companion to the free [IAC course on academeez](https://www.academeez.com/courses/terraform). Each lesson adds real infrastructure to this folder — folders, projects, IAM groups, service accounts, impersonation, and more.

**Prerequisites:** basic cloud provider knowledge and familiarity with Terraform or OpenTofu.

**Technologies:** OpenTofu (or Terraform), Terragrunt, GCP, mise, pre-commit.

**YouTube playlist:** [IAC course videos](https://www.youtube.com/playlist?list=PLEOJnF1eepkYPGzH278CQisotkZu-Bo0m)

### Lessons

#### 1. [Course Introduction](https://www.academeez.com/courses/terraform)

Overview of the course goals, technologies, prerequisites, and repository layout. Learn why managing cloud resources with IaC (instead of the web console) is the professional approach, and how this repo doubles as a starter kit for your own GCP projects.

#### 2. [Setup with mise](https://www.academeez.com/courses/terraform/setup-with-mise)

Set up a reproducible development environment declaratively using [mise](https://mise.jdx.dev/). Install and pin OpenTofu, Terragrunt, kubectl, and pre-commit so every developer and CI pipeline uses the same tool versions. Covers `mise.toml`, `mise.lock`, `mise trust`, and `mise install`.

#### 3. [Introduction to Terragrunt](https://www.academeez.com/courses/terraform/introduction-to-terragrunt)

Learn why monolithic IaC projects fail and how Terragrunt solves DRY violations across many small modules. Covers folder structure, `include` / `dependency` / `remote_state` blocks, shared `_env` configurations, and bootstrapping common GCP resources (root folder, shared folder, common project) with remote state in a GCS bucket.

#### 4. [Pretty code with pre-commit](https://www.academeez.com/courses/terraform/pre-commit)

Configure [pre-commit](https://pre-commit.com/) with [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) hooks to automatically run `terragrunt fmt` before every commit. Keeps HCL formatting consistent across the entire team with zero manual effort.

#### 5. [Security — Permissions, Roles, Groups, Impersonation](https://www.academeez.com/courses/terraform/permissions-roles-groups-impersonation)

Implement GCP security best practices in Terragrunt: assign users to groups (not direct permissions), follow the principle of least privilege, and use service account impersonation with short-lived tokens. Build Admin and DevOps groups, dedicated IAM service accounts, and automatic impersonation via `iam.yaml` files.

#### 6. [Terragrunt Unit](https://www.academeez.com/courses/terraform/unit)

Understand what a **unit** is — a single piece of infrastructure with its own state, defined by a `terragrunt.hcl` file in its folder. Learn `terragrunt plan --all`, why a root `terragrunt.hcl` is an anti-pattern, and migrate shared configuration to `root.hcl` so you can run Terragrunt from the repository root.

#### 7. [Terragrunt Stack](https://www.academeez.com/courses/terraform/stack)

Group units into reusable **stacks** using `terragrunt.stack.hcl`. Compare implicit stacks (duplicated folder trees) with explicit stacks (`terragrunt stack generate`). Learn `unit` and `stack` blocks, `values` vs `inputs`, `autoinclude`, and the catalog/live pattern for creating environments like `prod` and `non-prod` without code duplication.

---

## Quick start

1. **Install tools** — follow [CONTRIBUTING.md](CONTRIBUTING.md) to set up mise and pre-commit.
2. **Configure GCP** — copy example config files in [`iac/gcp/live/config/`](iac/gcp/live/config/) and fill in your org, billing, and region values.
3. **Authenticate** — `gcloud auth application-default login`
4. **Follow the course** — start with [lesson 1](https://www.academeez.com/courses/terraform) and work through the lessons in order.
5. **Use the catalog** — add the `catalog` block to your own live repo and scaffold units with `terragrunt catalog`.

---

## Repository structure

```
iac/
├── gcp/
│   ├── catalog/          # Reusable Terragrunt units and stacks
│   │   ├── units/        # folder, project, group, service-account, vpc, …
│   │   ├── stacks/       # Composed stacks (e.g. environment)
│   │   └── modules/      # Shared Terraform modules
│   └── live/             # Course infrastructure (consumes catalog)
│       ├── config/       # Org-specific configuration (gitignored)
│       ├── common/       # Shared folders and projects
│       ├── iam/          # Groups, service accounts, permissions
│       └── root.hcl      # Providers, remote state, impersonation, catalog
├── aws/                  # Placeholder — contributions welcome
└── azure/                # Placeholder — contributions welcome
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development environment setup with mise and pre-commit configuration.

---

**Like what you see?** Star this repo and share it with your team. It helps us keep building free, high-quality infrastructure education.
