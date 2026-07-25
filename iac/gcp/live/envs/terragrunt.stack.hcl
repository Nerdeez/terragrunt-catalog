
locals {
  env_stack_path  = "${get_repo_root()}/iac/gcp/catalog/stacks/env"
  billing_account = read_terragrunt_config(find_in_parent_folders("config/billing.hcl")).locals.billing_account
}

stack "non_prod_temp" {
  source = local.env_stack_path
  path   = "non-prod-temp"
  values = {
    name                      = "non-prod-temp-2"
    parent_folder_config_path = "${get_repo_root()}/iac/gcp/live/common/folders/root"
    billing_account           = local.billing_account
    project_inputs = {
      budget_amount = 20
    }
  }
}