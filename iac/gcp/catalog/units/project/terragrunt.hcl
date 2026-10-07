/**
 * Google Cloud project unit.
 *
 * Wraps terraform-google-modules/project-factory/google.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/project-factory/google?version=18.4.0"
}

inputs = merge(
  {
    random_project_id                       = try(values.random_project_id, false)
    random_project_id_length                = try(values.random_project_id_length, null)
    universe_prefix                         = try(values.universe_prefix, "")
    org_id                                  = try(values.org_id, null)
    domain                                  = try(values.domain, "")
    project_id                              = try(values.project_id, "")
    svpc_host_project_id                    = try(values.svpc_host_project_id, "")
    enable_shared_vpc_host_project          = try(values.enable_shared_vpc_host_project, false)
    folder_id                               = try(values.folder_id, "")
    group_name                              = try(values.group_name, "")
    principal_set                           = try(values.principal_set, "")
    group_role                              = try(values.group_role, "roles/editor")
    create_project_sa                       = try(values.create_project_sa, true)
    project_sa_name                         = try(values.project_sa_name, "project-service-account")
    project_sa_description                  = try(values.project_sa_description, null)
    sa_role                                 = try(values.sa_role, "")
    activate_apis                           = try(values.activate_apis, ["compute.googleapis.com"])
    activate_api_identities                 = try(values.activate_api_identities, [])
    usage_bucket_name                       = try(values.usage_bucket_name, "")
    usage_bucket_prefix                     = try(values.usage_bucket_prefix, "")
    shared_vpc_subnets                      = try(values.shared_vpc_subnets, [])
    labels                                  = try(values.labels, {})
    bucket_project                          = try(values.bucket_project, "")
    bucket_name                             = try(values.bucket_name, "")
    bucket_location                         = try(values.bucket_location, "US")
    bucket_versioning                       = try(values.bucket_versioning, false)
    bucket_labels                           = try(values.bucket_labels, {})
    bucket_force_destroy                    = try(values.bucket_force_destroy, false)
    bucket_ula                              = try(values.bucket_ula, true)
    bucket_pap                              = try(values.bucket_pap, "inherited")
    auto_create_network                     = try(values.auto_create_network, false)
    lien                                    = try(values.lien, false)
    disable_services_on_destroy             = try(values.disable_services_on_destroy, true)
    default_service_account                 = try(values.default_service_account, "disable")
    disable_dependent_services              = try(values.disable_dependent_services, true)
    budget_amount                           = try(values.budget_amount, null)
    budget_display_name                     = try(values.budget_display_name, null)
    budget_alert_pubsub_topic               = try(values.budget_alert_pubsub_topic, null)
    budget_monitoring_notification_channels = try(values.budget_monitoring_notification_channels, [])
    budget_alert_spent_percents             = try(values.budget_alert_spent_percents, [0.5, 0.7, 1.0])
    budget_alert_spend_basis                = try(values.budget_alert_spend_basis, "CURRENT_SPEND")
    budget_labels                           = try(values.budget_labels, {})
    budget_calendar_period                  = try(values.budget_calendar_period, null)
    budget_custom_period_start_date         = try(values.budget_custom_period_start_date, null)
    budget_custom_period_end_date           = try(values.budget_custom_period_end_date, null)
    vpc_service_control_attach_enabled      = try(values.vpc_service_control_attach_enabled, false)
    vpc_service_control_attach_dry_run      = try(values.vpc_service_control_attach_dry_run, false)
    vpc_service_control_perimeter_name      = try(values.vpc_service_control_perimeter_name, null)
    vpc_service_control_sleep_duration      = try(values.vpc_service_control_sleep_duration, "5s")
    grant_services_security_admin_role      = try(values.grant_services_security_admin_role, false)
    grant_network_role                      = try(values.grant_network_role, true)
    consumer_quotas                         = try(values.consumer_quotas, [])
    default_network_tier                    = try(values.default_network_tier, "")
    essential_contacts                      = try(values.essential_contacts, {})
    language_tag                            = try(values.language_tag, "en-US")
    tag_binding_values                      = try(values.tag_binding_values, [])
    cloud_armor_tier                        = try(values.cloud_armor_tier, null)
    deletion_policy                         = try(values.deletion_policy, "PREVENT")
  },
  try(values.name, "") != "" ? { name = values.name } : {},
  try(values.billing_account, "") != "" ? { billing_account = values.billing_account } : {},
)
