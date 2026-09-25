/**
 * IAM bindings for Google Cloud Secrets.
 *
 * Wraps terraform-google-modules/iam/google//modules/secret_manager_iam.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/iam/google//modules/secret_manager_iam?version=8.3.0"
}

inputs = merge(
  {
    secrets              = try(values.secrets, [])
    mode                 = try(values.mode, "additive")
    conditional_bindings = try(values.conditional_bindings, [])
  },
  try(values.project, "") != "" ? { project = values.project } : {},
  length(try(values.bindings, {})) > 0 ? { bindings = values.bindings } : {},
)