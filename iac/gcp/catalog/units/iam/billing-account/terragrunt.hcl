/**
 * IAM bindings for Google Cloud billing accounts.
 *
 * Wraps terraform-google-modules/iam/google//modules/billing_accounts_iam.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/iam/google//modules/billing_accounts_iam?version=8.3.0"
}

inputs = merge(
  {
    billing_account_ids = try(values.billing_account_ids, [])
    mode                = try(values.mode, "additive")
  },
  length(try(values.bindings, {})) > 0 ? { bindings = values.bindings } : {},
)
