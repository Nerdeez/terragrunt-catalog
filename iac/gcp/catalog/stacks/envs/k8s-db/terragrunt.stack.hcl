/**
 * Catalog stack: GCP environment foundation (folder + project).
 *
 * Instantiate from a live `terragrunt.stack.hcl` via `stack` blocks (e.g. prod, non-prod).
 * Each instance generates `folder/` and `project/` units under the stack `path`.
 *
 * Required `values` from the caller:
 *   - name                        — environment name (folder and project display name)
 *   - billing_account             — GCP billing account ID for the project
 *   - parent_folder_config_path   — Terragrunt path to the parent folder unit (dependency)
 *
 * Optional overrides:
 *   - folder_inputs  — merged over folder defaults (see locals.folder_defaults)
 *   - project_inputs — merged over project defaults (see locals.project_defaults)
 *
 * Managed Kubernetes and data-plane resources will be added in later units on this stack.
 */

locals {
  // Only keys that differ from catalog/units/folder try() defaults; parent/names are wired below.
  folder_defaults = {}
  // Only keys that differ from catalog/units/project try() defaults; folder_id, name, billing wired below.
  project_defaults = {
    random_project_id = true
    // Do not create the optional project-factory service account; use dedicated SAs from other units.
    create_project_sa = false
    // Google default compute SA: unit default is already "disable" (strip bindings / keys after GCP creates it).
  }
}

unit "folder" {
  source = "${get_repo_root()}/iac/gcp/catalog/units/folder"
  path   = "folder"

  autoinclude {
    dependency "parent" {
      config_path = values.parent_folder_config_path

      mock_outputs = {
        id = "folders/1111111"
      }
    }

    // Later keys win: defaults < folder_inputs < wired parent and name.
    inputs = merge(
      local.folder_defaults,
      try(values.folder_inputs, {}),
      {
        parent = dependency.parent.outputs.id
        names  = [values.name]
      }
    )
  }
}

unit "project" {
  source = "${get_repo_root()}/iac/gcp/catalog/units/project"
  path   = "project"

  autoinclude {
    dependency "folder" {
      config_path = unit.folder.path

      mock_outputs = {
        id = "folders/1111111111"
      }
    }

    // Later keys win: defaults < project_inputs < wired folder, name, and billing.
    inputs = merge(
      local.project_defaults,
      try(values.project_inputs, {}),
      {
        folder_id       = dependency.folder.outputs.id
        name            = values.name
        billing_account = values.billing_account
      }
    )
  }
}
