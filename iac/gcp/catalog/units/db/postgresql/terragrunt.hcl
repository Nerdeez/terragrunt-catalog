/**
 * Google Cloud SQL PostgreSQL unit.
 *
 * Wraps terraform-google-modules/sql-db/google//modules/postgresql.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/sql-db/google//modules/postgresql?version=28.3.0"
}

inputs = merge(
  {
    region                                   = try(values.region, "us-central1")
    edition                                  = try(values.edition, null)
    maintenance_version                      = try(values.maintenance_version, null)
    availability_type                        = try(values.availability_type, "ZONAL")
    enable_default_db                        = try(values.enable_default_db, true)
    db_name                                  = try(values.db_name, "default")
    enable_default_user                      = try(values.enable_default_user, true)
    user_name                                = try(values.user_name, "default")
    user_password                            = try(values.user_password, "")
    root_password                            = try(values.root_password, null)
    deletion_protection                      = try(values.deletion_protection, true)
    database_flags                           = try(values.database_flags, [])
    database_deletion_policy                 = try(values.database_deletion_policy, null)
    user_deletion_policy                     = try(values.user_deletion_policy, null)
    data_cache_enabled                       = try(values.data_cache_enabled, false)
    additional_users                         = try(values.additional_users, [])
    additional_databases                     = try(values.additional_databases, [])
    master_instance_name                     = try(values.master_instance_name, null)
    failover_dr_replica_name                 = try(values.failover_dr_replica_name, null)
    instance_type                            = try(values.instance_type, "CLOUD_SQL_INSTANCE")
    random_instance_name                     = try(values.random_instance_name, false)
    tier                                     = try(values.tier, "db-f1-micro")
    zone                                     = try(values.zone, null)
    secondary_zone                           = try(values.secondary_zone, null)
    follow_gae_application                   = try(values.follow_gae_application, null)
    activation_policy                        = try(values.activation_policy, "ALWAYS")
    deletion_protection_enabled              = try(values.deletion_protection_enabled, false)
    read_replica_deletion_protection_enabled = try(values.read_replica_deletion_protection_enabled, false)
    disk_autoresize                          = try(values.disk_autoresize, true)
    disk_autoresize_limit                    = try(values.disk_autoresize_limit, 0)
    disk_size                                = try(values.disk_size, 10)
    disk_type                                = try(values.disk_type, "PD_SSD")
    pricing_plan                             = try(values.pricing_plan, "PER_USE")
    maintenance_window_day                   = try(values.maintenance_window_day, 1)
    maintenance_window_hour                  = try(values.maintenance_window_hour, 23)
    maintenance_window_update_track          = try(values.maintenance_window_update_track, "canary")
    user_labels                              = try(values.user_labels, {})
    deny_maintenance_period                  = try(values.deny_maintenance_period, [])
    backup_configuration                     = try(values.backup_configuration, {})
    final_backup_config                      = try(values.final_backup_config, null)
    insights_config                          = try(values.insights_config, null)
    password_validation_policy_config        = try(values.password_validation_policy_config, null)
    ip_configuration                         = try(values.ip_configuration, {})
    read_replicas                            = try(values.read_replicas, [])
    read_replica_name_suffix                 = try(values.read_replica_name_suffix, "")
    db_charset                               = try(values.db_charset, "")
    db_collation                             = try(values.db_collation, "")
    iam_users                                = try(values.iam_users, [])
    create_timeout                           = try(values.create_timeout, "30m")
    update_timeout                           = try(values.update_timeout, "30m")
    delete_timeout                           = try(values.delete_timeout, "30m")
    encryption_key_name                      = try(values.encryption_key_name, null)
    module_depends_on                        = try(values.module_depends_on, [])
    read_replica_deletion_protection         = try(values.read_replica_deletion_protection, false)
    enable_random_password_special           = try(values.enable_random_password_special, false)
    connector_enforcement                    = try(values.connector_enforcement, false)
    enable_google_ml_integration             = try(values.enable_google_ml_integration, false)
    enable_dataplex_integration              = try(values.enable_dataplex_integration, false)
    database_integration_roles               = try(values.database_integration_roles, [])
    use_autokey                              = try(values.use_autokey, false)
    create_kms_key_handle                    = try(values.create_kms_key_handle, true)
    kms_key_handle_name                      = try(values.kms_key_handle_name, null)
    retain_backups_on_delete                 = try(values.retain_backups_on_delete, false)
    connection_pool_config                   = try(values.connection_pool_config, null)
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
  try(values.name, "") != "" ? { name = values.name } : {},
  try(values.database_version, "") != "" ? { database_version = values.database_version } : {},
)
