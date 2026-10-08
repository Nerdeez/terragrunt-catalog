/**
 * Artifact Registry repository unit.
 *
 * Wraps GoogleCloudPlatform/artifact-registry/google.
 * Consumers pass module inputs via the `inputs` block in live terragrunt.hcl,
 * or via `terragrunt.values.hcl` when scaffolding from the catalog (`values.*`).
 */

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///GoogleCloudPlatform/artifact-registry/google?version=0.8.2"
}

inputs = merge(
  {
    location                  = try(values.location, "us-central1")
    format                    = try(values.format, "DOCKER")
    mode                      = try(values.mode, "STANDARD_REPOSITORY")
    description               = try(values.description, null)
    labels                    = try(values.labels, {})
    docker_config             = try(values.docker_config, null)
    cleanup_policies          = try(values.cleanup_policies, {})
    cleanup_policy_dry_run    = try(values.cleanup_policy_dry_run, false)
    members                   = try(values.members, {})
    kms_key_name              = try(values.kms_key_name, null)
    remote_repository_config  = try(values.remote_repository_config, null)
    virtual_repository_config = try(values.virtual_repository_config, null)
  },
  try(values.project_id, "") != "" ? { project_id = values.project_id } : {},
  try(values.repository_id, "") != "" ? { repository_id = values.repository_id } : {},
)
