# Configuration

Live Terragrunt configuration files. Copy each `*.example.hcl` to its matching `*.hcl` file and fill in your values.

| Example (committed) | Local config (gitignored) |
|---------------------|---------------------------|
| `billing.example.hcl` | `billing.hcl` |
| `region.example.hcl` | `region.hcl` |
| `common.example.hcl` | `common.hcl` |

```bash
cp billing.example.hcl billing.hcl
cp region.example.hcl region.hcl
cp common.example.hcl common.hcl
```

Values are defined in a `locals` block in each file. `root.hcl` loads them with `read_terragrunt_config(find_in_parent_folders("config/billing.hcl"))`.
