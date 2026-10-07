/**
 * Google Cloud VPC network unit.
 *
 * Wraps terraform-google-modules/network/google.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/network/google?version=18.3.0"
}

inputs = merge(
  {
    routing_mode                              = try(values.routing_mode, "GLOBAL")
    shared_vpc_host                           = try(values.shared_vpc_host, false)
    subnets_region                            = try(values.subnets_region, null)
    secondary_ranges                          = try(values.secondary_ranges, {})
    routes                                    = try(values.routes, [])
    firewall_rules                            = try(values.firewall_rules, [])
    delete_default_internet_gateway_routes    = try(values.delete_default_internet_gateway_routes, false)
    description                               = try(values.description, "")
    auto_create_subnetworks                   = try(values.auto_create_subnetworks, false)
    mtu                                       = try(values.mtu, 0)
    ingress_rules                             = try(values.ingress_rules, [])
    egress_rules                              = try(values.egress_rules, [])
    enable_ipv6_ula                           = try(values.enable_ipv6_ula, false)
    internal_ipv6_range                       = try(values.internal_ipv6_range, null)
    network_firewall_policy_enforcement_order = try(values.network_firewall_policy_enforcement_order, null)
    network_profile                           = try(values.network_profile, null)
    bgp_always_compare_med                    = try(values.bgp_always_compare_med, false)
    bgp_best_path_selection_mode              = try(values.bgp_best_path_selection_mode, "LEGACY")
    bgp_inter_region_cost                     = try(values.bgp_inter_region_cost, null)
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
  try(values.network_name, "") != "" ? { network_name = values.network_name } : {},
  length(try(values.subnets, [])) > 0 ? { subnets = values.subnets } : {},
  try(length(keys(values.private_service_access_config)), 0) > 0 ? { private_service_access_config = values.private_service_access_config } : {},
)
