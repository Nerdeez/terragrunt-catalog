/**
 * Argo CD unit (cloud-agnostic module; GKE-friendly provider wiring).
 *
 * Installs the argo-cd Helm chart from https://github.com/argoproj/argo-helm.
 *
 * Provider auth (pick one via values):
 * - GKE (recommended): gke_cluster_name, gke_cluster_location, gke_project_id — uses
 *   google_client_config + google_container_cluster (same ADC as gcloud; no kubeconfig path).
 * - Other clouds: set kubeconfig_path or leave GKE fields empty.
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # Pin ref to the latest release tag: https://github.com/ywarezk/academeez-k8s-flux/releases
  # example: git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/k8s/catalog/modules/argocd?ref=v1.3.0 
  source = "git::https://github.com/ywarezk/academeez-k8s-flux.git//iac/k8s/catalog/modules/argocd"
}

generate "kubernetes_providers" {
  path      = "kubernetes_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
%{if try(values.gke_cluster_name, "") != "" && try(values.gke_cluster_location, "") != "" && try(values.gke_project_id, "") != ""}
# GKE: token from Application Default Credentials (gcloud auth application-default login / CI SA).
data "google_client_config" "argocd" {}

data "google_container_cluster" "argocd" {
  name     = "${values.gke_cluster_name}"
  location = "${values.gke_cluster_location}"
  project  = "${values.gke_project_id}"
}

locals {
  argocd_cluster_host  = "https://$${data.google_container_cluster.argocd.endpoint}"
  argocd_cluster_token = data.google_client_config.argocd.access_token
  argocd_cluster_ca    = base64decode(data.google_container_cluster.argocd.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes" {
  host                   = local.argocd_cluster_host
  token                  = local.argocd_cluster_token
  cluster_ca_certificate = local.argocd_cluster_ca
}

provider "helm" {
  kubernetes {
    host                   = local.argocd_cluster_host
    token                  = local.argocd_cluster_token
    cluster_ca_certificate = local.argocd_cluster_ca
  }
}
%{else}
provider "kubernetes" {
  config_path = "${replace(try(values.kubeconfig_path, "~/.kube/config"), "\\", "/")}"
}

provider "helm" {
  kubernetes = {
    config_path = "${replace(try(values.kubeconfig_path, "~/.kube/config"), "\\", "/")}"
  }
}
%{endif}
EOT
}

inputs = merge(
  {
    release_name  = try(values.release_name, "argocd")
    namespace     = try(values.namespace, "argocd")
    chart_version = try(values.chart_version, "10.10.0")
    helm_values   = try(values.helm_values, {})
    wait          = try(values.wait, true)
    timeout       = try(values.timeout, 600)
  },
)
