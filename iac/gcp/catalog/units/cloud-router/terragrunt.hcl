/**
 * Cloud Router + Cloud NAT unit.
 *
 * Wraps terraform-google-modules/cloud-router/google (NAT is configured via the
 * router `nats` block — see Google’s cloud-router NAT example).
 * Consumers pass module inputs via live `inputs` or `terragrunt.values.hcl` (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/cloud-router/google?version=9.1.0"
}

inputs = merge(
  {
    region                        = try(values.region, "us-central1")
    description                   = try(values.description, null)
    encrypted_interconnect_router = try(values.encrypted_interconnect_router, false)
    bgp                           = try(values.bgp, null)
    nats = length(try(values.nats, [])) > 0 ? values.nats : [
      {
        name                               = try(values.nat_gateway_name, "nat-gateway")
        source_subnetwork_ip_ranges_to_nat = try(values.nat_source_subnetwork_ip_ranges_to_nat, "ALL_SUBNETWORKS_ALL_IP_RANGES")
        log_config = {
          enable = try(values.nat_log_enable, true)
          filter = try(values.nat_log_filter, "ERRORS_ONLY")
        }
        subnetworks = try(values.nat_subnetworks, [])
      },
    ]
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
  try(values.name, "") != "" ? { name = values.name } : {},
  try(values.network, "") != "" ? { network = values.network } : {},
)
