locals {
  default_helm_values = {
    fullnameOverride = var.release_name
    server = {
      service = {
        type = "LoadBalancer"
      }
    }
    # Workshop / single-node clusters: avoid HA controller split
    controller = {
      replicas = 1
    }
    repoServer = {
      replicas = 1
    }
    applicationSet = {
      replicas = 1
    }
  }
  merged_values = merge(local.default_helm_values, var.helm_values)
}

resource "helm_release" "argocd" {
  name             = var.release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = var.wait
  timeout          = var.timeout

  values = [yamlencode(local.merged_values)]
}
