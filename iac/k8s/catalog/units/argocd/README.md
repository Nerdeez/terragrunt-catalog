<!-- Frontmatter
name: Argo CD (Helm)
description: Declarative Argo CD install via the official argo-helm chart.
tags:
  - unit
  - k8s
  - kubernetes
  - helm
  - argocd
  - gitops
-->

# Argo CD (Helm)

Bootstraps [Argo CD](https://argo-cd.readthedocs.io/) on any Kubernetes cluster using the official [**argo-cd** Helm chart](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd). Implementation module: [`../../modules/argocd`](../../modules/argocd). Chart repo: `https://argoproj.github.io/argo-helm`.

This is a **K8s** catalog unit (not under `gcp/catalog`). Create the cluster with your cloud catalog (for example [GKE](../../../gcp/catalog/units/gke/README.md)), then apply this unit.

## Prerequisites

1. Cluster exists and nodes are **Ready**.
2. **GKE (recommended):** Google credentials for Terraform (same as `gcloud` — `gcloud auth application-default login` or CI service account). Set `gke_cluster_name`, `gke_cluster_location`, and `gke_project_id`; the unit uses `google_client_config` + `google_container_cluster` — **no kubeconfig path**.
3. **Other clouds:** omit GKE fields and use **`kubeconfig_path`** (default `~/.kube/config`).

## Scaffolding

| Value | Required | Default | Description |
|-------|----------|---------|-------------|
| `gke_cluster_name` | for GKE | — | Cluster name (e.g. `data-agent`). |
| `gke_cluster_location` | for GKE | — | Zone or region (e.g. `us-central1-a` for zonal GKE). |
| `gke_project_id` | for GKE | — | Host project ID. |
| `chart_version` | no | `10.10.0` | [argo-cd chart](https://github.com/argoproj/argo-helm/releases) version (e.g. [argo-cd-10.10.0](https://github.com/argoproj/argo-helm/releases/tag/argo-cd-10.10.0) ships app `v3.5.4`); pin to match your `argocd` CLI. |
| `namespace` | no | `argocd` | Install namespace. |
| `release_name` | no | `argocd` | Helm release name. |
| `kubeconfig_path` | no | `~/.kube/config` | Fallback when GKE fields are not set. |
| `helm_values` | no | `{}` | Extra chart values (merged over unit defaults). |
| `wait` | no | `true` | Wait for Helm release ready. |
| `timeout` | no | `600` | Helm timeout (seconds). |

### Default chart values (module)

- `server.service.type = LoadBalancer` (public UI/API via cloud LB; adjust in `helm_values` for Ingress or ClusterIP + port-forward).
- `controller.replicas`, `repoServer.replicas`, `applicationSet.replicas` = **1** (workshop / single-node friendly).

Override via `helm_values` in live, for example:

```hcl
helm_values = {
  server = {
    service = {
      type = "ClusterIP"
    }
  }
}
```

## Consumption (live repository)

Apply **after** GKE (or any cluster) is up. Example for **data-agent-argo**:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "argocd" {
  path = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/k8s/catalog/units/argocd?ref=<version>"
}

dependency "gke" {
  config_path = "../gke"
}

dependency "project" {
  config_path = "../project"
}

inputs = merge(
  {
    chart_version = "10.10.0"
  },
  {
    gke_cluster_name     = dependency.gke.outputs.name
    gke_cluster_location = dependency.gke.outputs.location
    gke_project_id       = dependency.project.outputs.project_id
  },
)
```

The unit `terragrunt.hcl` pulls the module from this repo over git; pin `ref` to the latest release tag when consuming from live.

## Post-apply

1. Wait for `argocd-server` (and other pods) in namespace `argocd`.
2. If `LoadBalancer`: `kubectl get svc -n argocd argocd-server` → external IP.
3. Initial password: `argocd admin initial-password -n argocd`
4. Login: `argocd login <server> --username admin --password … --insecure` (self-signed cert) or `argocd login --core`
5. Deploy apps with `Application` manifests; destination `https://kubernetes.default.svc` for in-cluster.

## Module inputs / outputs

See [`../../modules/argocd`](../../modules/argocd) (`variables.tf`, `outputs.tf`). Chart-specific options: [argo-cd chart values](https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml).

## Notes

- This installs the **platform** only; DataAgent and other apps are separate `Application` resources in your app repo.
- Pin `chart_version` in `terragrunt.values.hcl`; chart ↔ app mapping is on [argo-helm releases](https://github.com/argoproj/argo-helm/releases).
- For production: tighten `server` exposure (Ingress + TLS), resources, and HA replicas in `helm_values`.
