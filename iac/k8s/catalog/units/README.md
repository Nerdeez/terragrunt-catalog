# K8s catalog units

Cross-cloud Terragrunt units that install software **into** an existing Kubernetes cluster (GitOps bootstrap, add-ons, etc.).

Unlike [`../../gcp/catalog/units`](../../gcp/catalog/units), these units do not call cloud provider APIs to create clusters. You need:

- A reachable API server (`kubectl get nodes` works)
- Credentials (default: kubeconfig path, usually after cloud-specific `get-credentials`)

State and `include "root"` still come from your **live** repository (for example `iac/live/root.hcl`).
