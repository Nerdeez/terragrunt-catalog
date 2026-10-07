/**
 * Google Kubernetes Engine (GKE) unit.
 *
 * Wraps terraform-google-modules/kubernetes-engine/google//modules/private-cluster.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google//modules/private-cluster?version=45.0.0"
}

inputs = merge(
  {
    description                            = try(values.description, "")
    regional                               = try(values.regional, true)
    region                                 = try(values.region, "us-central1")
    zones                                  = try(values.zones, [])
    network_project_id                     = try(values.network_project_id, "")
    kubernetes_version                     = try(values.kubernetes_version, "latest")
    master_authorized_networks             = try(values.master_authorized_networks, [])
    gcp_public_cidrs_access_enabled        = try(values.gcp_public_cidrs_access_enabled, null)
    enable_vertical_pod_autoscaling        = try(values.enable_vertical_pod_autoscaling, false)
    horizontal_pod_autoscaling             = try(values.horizontal_pod_autoscaling, true)
    http_load_balancing                    = try(values.http_load_balancing, true)
    service_external_ips                   = try(values.service_external_ips, false)
    insecure_kubelet_readonly_port_enabled = try(values.insecure_kubelet_readonly_port_enabled, null)
    datapath_provider                      = try(values.datapath_provider, "DATAPATH_PROVIDER_UNSPECIFIED")
    maintenance_start_time                 = try(values.maintenance_start_time, "05:00")
    maintenance_exclusions                 = try(values.maintenance_exclusions, [])
    maintenance_end_time                   = try(values.maintenance_end_time, "")
    maintenance_recurrence                 = try(values.maintenance_recurrence, "")
    additional_ip_range_pods               = try(values.additional_ip_range_pods, [])
    stack_type                             = try(values.stack_type, "IPV4")
    node_pools = try(values.node_pools, [
      {
        name         = "default-node-pool"
        machine_type = "e2-medium"
        min_count    = 1
        max_count    = 3
        auto_repair  = true
        auto_upgrade = true
      },
    ])
    windows_node_pools                    = try(values.windows_node_pools, [])
    node_pools_labels                     = try(values.node_pools_labels, {})
    node_pools_resource_labels            = try(values.node_pools_resource_labels, {})
    node_pools_resource_manager_tags      = try(values.node_pools_resource_manager_tags, {})
    node_pools_metadata                   = try(values.node_pools_metadata, {})
    node_pools_linux_node_configs_sysctls = try(values.node_pools_linux_node_configs_sysctls, {})
    node_pools_cgroup_mode                = try(values.node_pools_cgroup_mode, {})
    enable_cost_allocation                = try(values.enable_cost_allocation, false)
    resource_usage_export_dataset_id      = try(values.resource_usage_export_dataset_id, "")
    enable_network_egress_export          = try(values.enable_network_egress_export, false)
    enable_resource_consumption_export    = try(values.enable_resource_consumption_export, true)
    # Node auto-provisioning (NAP) off by default; not exposed via values.* — multiline
    # object defaults break terragrunt catalog scaffold HCL generation.
    cluster_autoscaling = {
      enabled                     = false
      autoscaling_profile         = "BALANCED"
      max_cpu_cores               = 0
      min_cpu_cores               = 0
      max_memory_gb               = 0
      min_memory_gb               = 0
      gpu_resources               = []
      auto_repair                 = true
      auto_upgrade                = true
      disk_size                   = 100
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
    node_pools_taints                        = try(values.node_pools_taints, {})
    node_pools_tags                          = try(values.node_pools_tags, {})
    node_pools_oauth_scopes                  = try(values.node_pools_oauth_scopes, {})
    network_tags                             = try(values.network_tags, [])
    stub_domains                             = try(values.stub_domains, {})
    upstream_nameservers                     = try(values.upstream_nameservers, [])
    non_masquerade_cidrs                     = try(values.non_masquerade_cidrs, ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])
    ip_masq_resync_interval                  = try(values.ip_masq_resync_interval, "60s")
    ip_masq_link_local                       = try(values.ip_masq_link_local, false)
    configure_ip_masq                        = try(values.configure_ip_masq, false)
    logging_service                          = try(values.logging_service, "logging.googleapis.com/kubernetes")
    monitoring_service                       = try(values.monitoring_service, "monitoring.googleapis.com/kubernetes")
    create_service_account                   = try(values.create_service_account, true)
    grant_registry_access                    = try(values.grant_registry_access, true)
    registry_project_ids                     = try(values.registry_project_ids, [])
    service_account                          = try(values.service_account, "")
    service_account_name                     = try(values.service_account_name, "")
    boot_disk_kms_key                        = try(values.boot_disk_kms_key, null)
    issue_client_certificate                 = try(values.issue_client_certificate, false)
    cluster_ipv4_cidr                        = try(values.cluster_ipv4_cidr, null)
    cluster_resource_labels                  = try(values.cluster_resource_labels, {})
    deploy_using_private_endpoint            = try(values.deploy_using_private_endpoint, false)
    enable_private_endpoint                  = try(values.enable_private_endpoint, false)
    enable_private_nodes                     = try(values.enable_private_nodes, true)
    master_ipv4_cidr_block                   = try(values.master_ipv4_cidr_block, "172.16.0.0/28")
    private_endpoint_subnetwork              = try(values.private_endpoint_subnetwork, null)
    master_global_access_enabled             = try(values.master_global_access_enabled, true)
    dns_cache                                = try(values.dns_cache, false)
    authenticator_security_group             = try(values.authenticator_security_group, null)
    identity_namespace                       = try(values.identity_namespace, "enabled")
    enable_mesh_certificates                 = try(values.enable_mesh_certificates, false)
    release_channel                          = try(values.release_channel, "REGULAR")
    gateway_api_channel                      = try(values.gateway_api_channel, null)
    add_cluster_firewall_rules               = try(values.add_cluster_firewall_rules, false)
    add_master_webhook_firewall_rules        = try(values.add_master_webhook_firewall_rules, false)
    firewall_priority                        = try(values.firewall_priority, 1000)
    firewall_inbound_ports                   = try(values.firewall_inbound_ports, ["8443", "9443", "15017"])
    add_shadow_firewall_rules                = try(values.add_shadow_firewall_rules, false)
    shadow_firewall_rules_priority           = try(values.shadow_firewall_rules_priority, 999)
    shadow_firewall_rules_log_config         = try(values.shadow_firewall_rules_log_config, { metadata = "INCLUDE_ALL_METADATA" })
    enable_confidential_nodes                = try(values.enable_confidential_nodes, false)
    enable_gcfs                              = try(values.enable_gcfs, false)
    enable_secret_manager_addon              = try(values.enable_secret_manager_addon, false)
    enable_fqdn_network_policy               = try(values.enable_fqdn_network_policy, null)
    enable_cilium_clusterwide_network_policy = try(values.enable_cilium_clusterwide_network_policy, false)
    security_posture_mode                    = try(values.security_posture_mode, "DISABLED")
    security_posture_vulnerability_mode      = try(values.security_posture_vulnerability_mode, "VULNERABILITY_DISABLED")
    disable_default_snat                     = try(values.disable_default_snat, false)
    enable_default_node_pools_metadata       = try(values.enable_default_node_pools_metadata, true)
    notification_config_topic                = try(values.notification_config_topic, "")
    notification_filter_event_type           = try(values.notification_filter_event_type, [])
    deletion_protection                      = try(values.deletion_protection, false)
    enable_tpu                               = try(values.enable_tpu, false)
    filestore_csi_driver                     = try(values.filestore_csi_driver, false)
    network_policy                           = try(values.network_policy, false)
    network_policy_provider                  = try(values.network_policy_provider, "CALICO")
    initial_node_count                       = try(values.initial_node_count, 1)
    remove_default_node_pool                 = try(values.remove_default_node_pool, true)
    disable_legacy_metadata_endpoints        = try(values.disable_legacy_metadata_endpoints, true)
    default_max_pods_per_node                = try(values.default_max_pods_per_node, 110)
    database_encryption                      = try(values.database_encryption, [{ state = "DECRYPTED", key_name = "" }])
    enable_shielded_nodes                    = try(values.enable_shielded_nodes, true)
    enable_binary_authorization              = try(values.enable_binary_authorization, false)
    node_metadata                            = try(values.node_metadata, "GKE_METADATA")
    cluster_dns_provider                     = try(values.cluster_dns_provider, "PROVIDER_UNSPECIFIED")
    cluster_dns_scope                        = try(values.cluster_dns_scope, "DNS_SCOPE_UNSPECIFIED")
    cluster_dns_domain                       = try(values.cluster_dns_domain, "")
    additive_vpc_scope_dns_domain            = try(values.additive_vpc_scope_dns_domain, "")
    gce_pd_csi_driver                        = try(values.gce_pd_csi_driver, true)
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
  try(values.name, "") != "" ? { name = values.name } : {},
  try(values.network, "") != "" ? { network = values.network } : {},
  try(values.subnetwork, "") != "" ? { subnetwork = values.subnetwork } : {},
  try(values.ip_range_pods, "") != "" ? { ip_range_pods = values.ip_range_pods } : {},
  try(values.ip_range_services, "") != "" ? { ip_range_services = values.ip_range_services } : {},
)
