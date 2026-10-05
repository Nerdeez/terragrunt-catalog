/**
 * Live environments: prod and non-prod.
 *
 * Each `stack` block instantiates the k8s-db catalog stack, which scaffolds a GCP
 * folder and project under this directory (`prod/`, `non-prod/`).
 *
 * Catalog stack: iac/gcp/catalog/stacks/envs/k8s-db (see README there for values).
 */

locals {
  // Shared billing account for all environment projects (iac/gcp/live/config/billing.hcl).
  billing_config  = read_terragrunt_config(find_in_parent_folders("config/billing.hcl")).locals
  billing_account = local.billing_config.billing_account

  // Monthly billing budget (USD) per environment project; uses project unit budget_* defaults for alerts.
  project_budget_amount = 20
}

stack "prod" {
  source = "${get_repo_root()}/iac/gcp/catalog/stacks/envs/k8s-db"
  path   = "prod"

  values = {
    name                      = "prod"
    billing_account           = local.billing_account
    parent_folder_config_path = "${get_repo_root()}/iac/gcp/live/common/folders/root"

    project_inputs = {
      budget_amount = local.project_budget_amount
    }
  }
}

stack "non-prod" {
  source = "${get_repo_root()}/iac/gcp/catalog/stacks/envs/k8s-db"
  path   = "non-prod"

  values = {
    name                      = "non-prod"
    billing_account           = local.billing_account
    parent_folder_config_path = "${get_repo_root()}/iac/gcp/live/common/folders/root"

    project_inputs = {
      budget_amount = local.project_budget_amount
    }
  }
}
