/**
 * Google Cloud Storage bucket unit.
 *
 * Wraps terraform-google-modules/cloud-storage/google.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/cloud-storage/google?version=12.4.0"
}

inputs = merge(
  {
    prefix                   = try(values.prefix, "")
    location                 = try(values.location, "EU")
    storage_class            = try(values.storage_class, "STANDARD")
    randomize_suffix         = try(values.randomize_suffix, false)
    labels                   = try(values.labels, {})
    public_access_prevention = try(values.public_access_prevention, "inherited")
    versioning               = try(values.versioning, {})
    autoclass                = try(values.autoclass, {})
    bucket_policy_only       = try(values.bucket_policy_only, {})
    force_destroy            = try(values.force_destroy, {})
    default_event_based_hold = try(values.default_event_based_hold, {})
    hierarchical_namespace   = try(values.hierarchical_namespace, {})
    encryption_key_names     = try(values.encryption_key_names, {})
    retention_policy         = try(values.retention_policy, {})
    soft_delete_policy       = try(values.soft_delete_policy, {})
    logging                  = try(values.logging, {})
    website                  = try(values.website, {})
    custom_placement_config  = try(values.custom_placement_config, {})
    folders                  = try(values.folders, {})
    lifecycle_rules          = try(values.lifecycle_rules, [])
    bucket_lifecycle_rules   = try(values.bucket_lifecycle_rules, {})
    cors                     = try(values.cors, [])
    ip_filter                = try(values.ip_filter, {})
    set_admin_roles          = try(values.set_admin_roles, false)
    admins                   = try(values.admins, [])
    bucket_admins            = try(values.bucket_admins, {})
    set_creator_roles        = try(values.set_creator_roles, false)
    creators                 = try(values.creators, [])
    bucket_creators          = try(values.bucket_creators, {})
    set_viewer_roles         = try(values.set_viewer_roles, false)
    viewers                  = try(values.viewers, [])
    bucket_viewers           = try(values.bucket_viewers, {})
    set_storage_admin_roles  = try(values.set_storage_admin_roles, false)
    storage_admins           = try(values.storage_admins, [])
    bucket_storage_admins    = try(values.bucket_storage_admins, {})
    set_hmac_key_admin_roles = try(values.set_hmac_key_admin_roles, false)
    hmac_key_admins          = try(values.hmac_key_admins, [])
    bucket_hmac_key_admins   = try(values.bucket_hmac_key_admins, {})
    set_hmac_access          = try(values.set_hmac_access, false)
    hmac_service_accounts    = try(values.hmac_service_accounts, {})
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
  length(try(values.names, [])) > 0 ? { names = values.names } : {},
)
