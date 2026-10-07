/**
 * Google Cloud service account unit.
 *
 * Wraps terraform-google-modules/service-accounts/google.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google?version=5.1.0"
}

inputs = merge(
  {
    prefix             = try(values.prefix, "")
    names              = try(values.names, [])
    project_roles      = try(values.project_roles, [])
    grant_billing_role = try(values.grant_billing_role, false)
    billing_account_id = try(values.billing_account_id, "")
    grant_xpn_roles    = try(values.grant_xpn_roles, true)
    org_id             = try(values.org_id, "")
    generate_keys      = try(values.generate_keys, false)
    display_name       = try(values.display_name, "Terraform-managed service account")
    description        = try(values.description, "")
    descriptions       = try(values.descriptions, [])
    disabled           = try(values.disabled, {})
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
)
