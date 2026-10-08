output "release_name" {
  description = "Helm release name."
  value       = helm_release.argocd.name
}

output "namespace" {
  description = "Namespace where Argo CD is installed."
  value       = helm_release.argocd.namespace
}

output "chart_version" {
  description = "Installed Helm chart version."
  value       = helm_release.argocd.version
}

output "status" {
  description = "Helm release status."
  value       = helm_release.argocd.status
}
