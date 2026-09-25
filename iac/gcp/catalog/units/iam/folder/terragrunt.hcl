/**
 * IAM bindings for Google Cloud folders.
 *
 * Wraps terraform-google-modules/iam/google//modules/folders_iam.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/iam/google//modules/folders_iam?version=8.3.0"
}

inputs = merge(
  {
    folders              = try(values.folders, [])
    mode                 = try(values.mode, "additive")
    conditional_bindings = try(values.conditional_bindings, [])
  },
  length(try(values.bindings, {})) > 0 ? { bindings = values.bindings } : {},
)
