/**
 * Using this stack we can create an environment
 * An environment is an opionionated k8s environment
 * Please supply the following values:
 * - name: the name of the environment
 * - parent_folder_config_path: path to the parent folder unit whose id becomes this environment's parent folder
 * - billing_account: billing account ID to attach to the environment's project
 * Optional values:
 * - folder_inputs: overrides catalog folder defaults (e.g. deletion_protection)
 * - project_inputs: overrides catalog project defaults (e.g. budget_amount)
 */

locals {
  units_folder = "${get_repo_root()}/iac/gcp/catalog/units"

  default_folder_inputs = {
    deletion_protection = false
  }

  default_project_inputs = {
    random_project_id       = true
    deletion_policy         = "DELETE"
    create_project_sa       = false
    default_service_account = "disable"
  }
}

unit "folder" {
  source = "${local.units_folder}/folder"
  path   = "folder"

  autoinclude {
    dependency "parent_folder" {
      config_path = values.parent_folder_config_path
      mock_outputs = {
        id = "folders/mock-parent-folder"
      }
    }
    inputs = merge(
      local.default_folder_inputs,
      try(values.folder_inputs, {}),
      {
        parent = dependency.parent_folder.outputs.id
        names  = [values.name]
      },
    )
  }
}

unit "project" {
  source = "${local.units_folder}/project"
  path   = "project"

  autoinclude {
    dependency "folder" {
      config_path = unit.folder.path
      mock_outputs = {
        id = "folders/mock-folder"
      }
    }
    inputs = merge(
      local.default_project_inputs,
      try(values.project_inputs, {}),
      {
        folder_id       = dependency.folder.outputs.id
        name            = values.name
        billing_account = values.billing_account
      },
    )
  }
}