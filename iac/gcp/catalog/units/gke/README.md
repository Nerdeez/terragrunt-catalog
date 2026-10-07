<!-- Frontmatter
name: GCP GKE - Managed K8S
description: Create a private Google Kubernetes Engine cluster with VPC-native networking.
tags:
  - unit
  - gcp
  - google
  - gke
  - k8s
-->

# GCP GKE (private cluster)

Creates a **VPC-native GKE cluster** with **private nodes** using the [terraform-google-modules/kubernetes-engine/google//modules/private-cluster](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/private-cluster) submodule. The pinned module version lives only in [`terragrunt.hcl`](./terragrunt.hcl) (`terraform.source`).

Designed for workloads that expose **only load balancers** on the public internet: nodes use internal IPs (`enable_private_nodes = true` by default). The control plane endpoint remains **public** by default (`enable_private_endpoint = false`) so operators can run `kubectl` from outside the VPC when [master authorized networks](#master-authorized-networks) allow it.

Pair this unit with the [VPC unit](../vpc/README.md): pass `network`, `subnetwork`, and the **secondary range names** (`ip_range_pods`, `ip_range_services`) that match `secondary_ranges` on your node subnet.

## Scaffolding

From the catalog TUI, select this unit and press `s` to scaffold it into your working directory. Terragrunt copies the unit files in place and prompts for each `values.*` reference (press `x` on optional fields to keep the `try()` default). It writes a `terragrunt.values.hcl` with the answers you provide.

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `project_id` | yes | — | Project ID hosting the cluster. |
| `name` | yes | — | Cluster name. |
| `network` | yes | — | VPC network name (not self link). |
| `subnetwork` | yes | — | Subnetwork name for nodes (same region as the cluster). |
| `ip_range_pods` | yes | — | **Name** of the subnet secondary range for pods. |
| `ip_range_services` | yes | — | **Name** of the subnet secondary range for services. |
| `region` | no | `us-central1` | Region (required for regional clusters). |
| `regional` | no | `true` | Regional cluster; set `false` for zonal (then set `zones`). |
| `zones` | no | `[]` | Zones for a zonal cluster. |
| `enable_private_nodes` | no | `true` | Nodes without public IPs. |
| `enable_private_endpoint` | no | `false` | If `true`, API server is only on the private endpoint. |
| `master_ipv4_cidr_block` | no | `172.16.0.0/28` | RFC1918 range for the hosted master (private cluster). |
| `http_load_balancing` | no | `true` | Enable HTTP(S) load balancing (Ingress / Gateway). |
| `horizontal_pod_autoscaling` | no | `true` | Enable HPA addon. |
| `network_policy` | no | `false` | Calico network policy addon. |
| `release_channel` | no | `REGULAR` | GKE release channel (`RAPID`, `REGULAR`, `STABLE`). |
| `deletion_protection` | no | `false` | Block Terraform destroy (module default is `true`). |
| `remove_default_node_pool` | no | `true` | Drop bootstrap pool after custom `node_pools` apply. |
| `initial_node_count` | no | `1` | Nodes in the default pool before removal. |
| `grant_registry_access` | no | `true` | Grant cluster SA Artifact Registry / GCR read on the project. |
| `node_pools` | no | one `e2-medium` pool | See [node pools](#node-pools). |
| `master_authorized_networks` | no | `[]` | CIDRs allowed to reach the public control plane endpoint. |

Set the six **required** values (or wire them via `dependency` in live) before `terragrunt apply`.

After scaffolding, wire dependencies on **project** and **VPC** in your live repository.

In a stack `unit` block you only need to set the values you care about; optional keys use the `try()` defaults in the catalog unit. Required keys can be omitted from `values` when you supply them via an `autoinclude` `inputs` block instead (see [catalog units README](../README.md)).

## Consumption

Include this unit from your live repository and supply module inputs in your `terragrunt.hcl`:

```hcl
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "gke" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/gcp/catalog/units/gke?ref=<version>"
}

dependency "project" {
  config_path = "../project"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = merge(
  {
    name              = "data-agent"
    region            = "us-central1"
    ip_range_pods     = "data-agent-gke-pods"
    ip_range_services = "data-agent-gke-services"
    master_authorized_networks = [
      {
        cidr_block   = "203.0.113.10/32"
        display_name = "admin"
      },
    ]
  },
  {
    project_id = dependency.project.outputs.project_id
    network    = dependency.vpc.outputs.network_name
    subnetwork = "data-agent-gke"
  },
)
```

Project- and network-specific values belong in the **live** repository, not in the catalog.

### Master authorized networks

With `enable_private_endpoint = false`, the cluster has a **public** control plane endpoint. If `master_authorized_networks` is empty, only Google-managed paths (for example node IPs) are allowed—**your laptop cannot run `kubectl` until you add your egress IP** (or use a bastion / Cloud Shell with appropriate access).

### Node pools

Default pool (cost-conscious workshop size):

```hcl
node_pools = [
  {
    name         = "default-node-pool"
    machine_type = "e2-medium"
    min_count    = 1
    max_count    = 3
    auto_repair  = true
    auto_upgrade = true
  },
]
```

Set `spot = true` on a pool map entry for cheaper lab nodes if brief interruptions are acceptable.

### Outbound internet from private nodes

This unit does **not** create Cloud NAT. Private nodes still need NAT (or permissive routing) to pull images from the public internet unless you use private Artifact Registry and Private Google Access only. Add a router/NAT unit or module in live when needed.

## Required inputs

| Input | Type | Description |
|-------|------|-------------|
| `project_id` | `string` | Host project ID. |
| `name` | `string` | Cluster name. |
| `network` | `string` | VPC **name** (`network_name` from the VPC unit). |
| `subnetwork` | `string` | Subnet **name** (not the `region/name` map key). |
| `ip_range_pods` | `string` | Secondary range **name** for pods. |
| `ip_range_services` | `string` | Secondary range **name** for services. |

## Common optional inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `region` | `string` | `us-central1` | Cluster region. |
| `regional` | `bool` | `true` | Regional vs zonal cluster. |
| `kubernetes_version` | `string` | `latest` | Master version (or `latest` in region). |
| `enable_private_nodes` | `bool` | `true` | Private node IPs only. |
| `enable_private_endpoint` | `bool` | `false` | Private-only API server endpoint. |
| `master_ipv4_cidr_block` | `string` | `172.16.0.0/28` | Control plane peering CIDR. |
| `http_load_balancing` | `bool` | `true` | External/internal HTTP(S) LB integration. |
| `deletion_protection` | `bool` | `false` | Prevent Terraform destroy. |
| `identity_namespace` | `string` | `enabled` | Workload Identity pool (`enabled` → project `.svc.id.goog`). |

See the [module inputs](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/private-cluster?tab=inputs) for the full list (match the version in [`terragrunt.hcl`](./terragrunt.hcl) when comparing defaults).

## Outputs

Common outputs for downstream units (Argo CD bootstrap, kubectl, etc.):

| Output | Description |
|--------|-------------|
| `name` | Cluster name. |
| `endpoint` | API server URL. |
| `ca_certificate` | Cluster CA (sensitive). |
| `location` | Region or zone. |
| `region` | Cluster region. |
| `master_version` | Current control plane version. |
| `service_account` | Default node service account email. |
| `identity_namespace` | Workload Identity pool. |

Configure kubectl after apply:

```bash
gcloud container clusters get-credentials <name> --region <region> --project <project_id>
```

See the [module outputs](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/private-cluster?tab=outputs) for the full list.
