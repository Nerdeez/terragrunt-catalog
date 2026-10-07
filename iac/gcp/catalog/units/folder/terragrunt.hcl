/**
 * Google Cloud folder unit.
 *
 * Wraps terraform-google-modules/folders/google.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/folders/google?version=5.2.0"
}

inputs = merge(
  {
    prefix              = try(values.prefix, "")
    deletion_protection = try(values.deletion_protection, true)
    set_roles           = try(values.set_roles, false)
    per_folder_admins   = try(values.per_folder_admins, {})
    all_folder_admins   = try(values.all_folder_admins, [])
    folder_admin_roles = try(values.folder_admin_roles, [
      "roles/owner",
      "roles/resourcemanager.folderViewer",
      "roles/resourcemanager.projectCreator",
      "roles/compute.networkAdmin",
    ])
  },
  try(values.parent, "") != "" ? { parent = values.parent } : {},
  length(try(values.names, [])) > 0 ? { names = values.names } : {},
)
