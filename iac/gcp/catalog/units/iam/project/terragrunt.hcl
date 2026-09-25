/**
 * IAM bindings for Google Cloud projects.
 *
 * Wraps terraform-google-modules/iam/google//modules/projects_iam.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/iam/google//modules/projects_iam?version=8.3.0"
}

inputs = merge(
  {
    projects             = try(values.projects, [])
    mode                 = try(values.mode, "additive")
    conditional_bindings = try(values.conditional_bindings, [])
  },
  length(try(values.bindings, {})) > 0 ? { bindings = values.bindings } : {},
)
