<!-- Frontmatter
name: GCP Cloud Router
description: Cloud Router with optional Cloud NAT for private workload egress.
tags:
  - unit
  - gcp
  - google
  - cloud-router
  - router
  - nat
-->

# GCP Cloud Router (with Cloud NAT)

Creates a regional **Cloud Router** with **Cloud NAT** so private workloads (for example GKE nodes with `enable_private_nodes = true`) can reach the public internet for image pulls and external APIs.

Google’s Terraform guidance is to configure NAT on the **[terraform-google-modules/cloud-router/google](https://registry.terraform.io/modules/terraform-google-modules/cloud-router/google/latest)** module (`nats` block), not a separate NAT-only module. See the upstream [NAT example](https://github.com/terraform-google-modules/terraform-google-cloud-router/blob/main/examples/nat/main.tf). The pinned module version lives only in [`terragrunt.hcl`](./terragrunt.hcl) (`terraform.source`).

Pair with the [VPC unit](../vpc/README.md) (same `network` name and `region` as your node subnet). Apply **after** the VPC exists; apply **before** or with GKE if private nodes must pull images from the public internet.

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold. Terragrunt prompts for each `values.*` reference (`x` keeps the `try()` default).

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `project_id` | yes | — | Host project ID. |
| `name` | yes | — | Cloud Router name (for example `data-agent-router`). |
| `network` | yes | — | VPC **name** (same as VPC `network_name`). |
| `region` | no | `us-central1` | Region for the router and NAT (match GKE subnet region). |
| `nat_gateway_name` | no | `nat-gateway` | Name of the NAT configuration on the router. |
| `nat_source_subnetwork_ip_ranges_to_nat` | no | `ALL_SUBNETWORKS_ALL_IP_RANGES` | NAT scope; use `LIST_OF_SUBNETWORKS` for a single subnet (set `nat_subnetworks`). |
| `nat_subnetworks` | no | `[]` | When using `LIST_OF_SUBNETWORKS`, list of `{ name, source_ip_ranges_to_nat, secondary_ip_range_names }` (subnet **self-link** in `name`). |
| `nat_log_enable` | no | `true` | NAT logging. |
| `nat_log_filter` | no | `ERRORS_ONLY` | Log filter (`ALL`, `ERRORS_ONLY`, `TRANSLATIONS_ONLY`). |
| `nats` | no | built from above | Override the entire `nats` list for advanced configs (advanced users). |
| `bgp` | no | `null` | BGP block if the router is also used for BGP (not needed for NAT-only). |

## Consumption

### Simple (NAT all subnets in the region)

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "project" {
  config_path = "../project"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = merge(
  {
    name   = "data-agent-router"
    region = "us-central1"
  },
  {
    project_id = dependency.project.outputs.project_id
    network    = dependency.vpc.outputs.network_name
  },
)
```

Default NAT uses `ALL_SUBNETWORKS_ALL_IP_RANGES` — fine for a single-subnet workshop VPC.

### Scoped to the GKE subnet (recommended for tighter labs)

Use `LIST_OF_SUBNETWORKS` and the subnet self-link from the network module (key is `region/subnet_name`):

```hcl
inputs = merge(
  {
    name                                   = "data-agent-router"
    region                                 = "us-central1"
    nat_source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    nat_subnetworks = [
      {
        name                     = dependency.vpc.outputs.subnets["us-central1/data-agent-gke"].self_link
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = [
          "data-agent-gke-pods",
          "data-agent-gke-services",
        ]
      },
    ]
  },
  {
    project_id = dependency.project.outputs.project_id
    network    = dependency.vpc.outputs.network_name
  },
)
```

Or pass a full `nats` list in `terragrunt.values.hcl` / live `inputs` (same shape as the [module `nats` variable](https://registry.terraform.io/modules/terraform-google-modules/cloud-router/google/latest?tab=inputs)).

## Required inputs (module)

| Input | Type | Description |
|-------|------|-------------|
| `project_id` | `string` | Project ID (catalog: `values.project_id`). |
| `name` | `string` | Router name. |
| `network` | `string` | VPC name or self link. |
| `region` | `string` | Router region. |

## Outputs

| Output | Description |
|--------|-------------|
| `router` | Created `google_compute_router`. |
| `nat` | Created `google_compute_router_nat` map. |

See the [module outputs](https://registry.terraform.io/modules/terraform-google-modules/cloud-router/google/latest?tab=outputs) for details.

## Notes

- NAT is billed per gateway and per GB processed; a single regional NAT is usually enough for this workshop.
- Private Google Access on the subnet still helps reach Google APIs; NAT is for **general** internet egress.
- Does not replace firewall rules; default VPC egress is typically allow-outbound.
