variable "release_name" {
  type        = string
  description = "Helm release name."
  default     = "argocd"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for Argo CD."
  default     = "argocd"
}

variable "chart_version" {
  type        = string
  description = "argo-helm argo-cd chart version (pin; align app version with your argocd CLI)."
}

variable "helm_values" {
  type        = map(any)
  description = "Values passed to the argo-cd Helm chart (merged over module defaults)."
  default     = {}
}

variable "wait" {
  type        = bool
  description = "Wait for Helm release to become ready."
  default     = true
}

variable "timeout" {
  type        = number
  description = "Helm install/upgrade timeout in seconds."
  default     = 600
}
