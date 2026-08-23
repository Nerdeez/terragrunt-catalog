# Live templates

Boilerplate templates for scaffolding **repetitive live files** — configuration and layout that every Terragrunt live repository needs, but that are not deployable catalog units.

Unlike [`units/`](../units/) (infrastructure with their own state), templates generate shared live files: `root.hcl`, `config/`, and similar.

Use either:

- **`terragrunt catalog github.com/Nerdeez/terragrunt-catalog`** — browse templates in the catalog TUI and press `s` to scaffold (no `catalog {}` block required when the repo URL is passed on the CLI)
- **`terragrunt scaffold 'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/config?ref=<version>'`** — scaffold a template directly (quote the URL in zsh — `?` is a glob character)

Once `root.hcl` exists with a `catalog {}` block, run `terragrunt catalog` with no arguments.

Templates can be composed: one template may declare another as a Boilerplate dependency (for example, root depends on config).

## Templates

| Template | Path | Purpose |
|----------|------|---------|
| **config** | [`templates/config/`](config/) | `config/` folder — org, billing, and region values |
| **root** | [`templates/root/`](root/) | `root.hcl` — providers, remote state, catalog block |

More templates may be added here as recurring live patterns emerge.

## Common workflows

### New live environment

A developer starting a project scaffolds **root** — it depends on **config**, so both are created in one step:

```
terragrunt catalog github.com/Nerdeez/terragrunt-catalog   →   select root   →   root.hcl + config/
```

Or scaffold directly:

```bash
cd iac/live   # or iac/gcp/live

terragrunt scaffold \
  'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/root?ref=<version>' \
  --output-folder .
```

The root template runs the config template first (prompts for GCP values), then writes `root.hcl`. This avoids two setup problems:

1. **No `catalog {}` yet** — pass the catalog repo URL on the CLI: `terragrunt catalog github.com/Nerdeez/terragrunt-catalog`. After `root.hcl` is generated, `terragrunt catalog` works with no arguments.
2. **`root.hcl` reads `config/*.hcl`** — the config dependency ensures those files exist before `root.hcl` is rendered.

For a new environment, scaffold bootstrap units (folder, project) from the catalog after root — see [`root/README.md`](root/README.md).

### Join an existing project

A developer joining a shared repo scaffolds **config** only — `root.hcl` and example files are already committed; they generate local gitignored `*.hcl` files.

**Catalog TUI** (from the live directory):

```bash
terragrunt catalog github.com/Nerdeez/terragrunt-catalog
```

Select the **Live config template**, press `s`, and scaffold into the live directory.

**Scaffold directly:**

```bash
terragrunt scaffold \
  'git::https://github.com/Nerdeez/terragrunt-catalog.git//iac/gcp/catalog/templates/config?ref=<version>' \
  --output-folder .
```

See [`config/README.md`](config/README.md) for config-specific variables and `gcloud` commands.

## After scaffolding

1. Commit shared files (`root.hcl`, `config/README.md`, `config/*.example.hcl`).
2. Keep gitignored `config/*.hcl` local (or regenerate via the config template).
3. Run `terragrunt catalog` to scaffold infrastructure units.

## Catalog layout

| Path | What it scaffolds |
|------|-------------------|
| [`units/`](../units/) | Deployable infrastructure (folder, project, VPC, …) |
| [`stacks/`](../stacks/) | Composed groups of units |
| **`templates/`** | Repetitive live files (config, root, …) |
