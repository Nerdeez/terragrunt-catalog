/**
 * The root terragrunt will contain:
 *    - common provider configurations
 *    - remote state configuration
 *    - impersonation logic
 *    - catalog configuration (terragrunt catalog / scaffold)
 *
 * Created December 14th, 2024
 * @author ywarezk
 */

locals {
  region_config   = read_terragrunt_config(find_in_parent_folders("config/region.hcl")).locals
  billing_config  = read_terragrunt_config(find_in_parent_folders("config/billing.hcl")).locals
  common_config   = read_terragrunt_config(find_in_parent_folders("config/common.hcl")).locals
  iam             = try(yamldecode(file(find_in_parent_folders("iam.yaml"))), { "email" : "" })
  region          = local.region_config.region
  billing_project = local.billing_config.billing_project
  billing_account = local.billing_config.billing_account
  common_project  = local.common_config.common_project
  org_id          = local.common_config.org_id
  customer_id     = local.common_config.customer_id
}

catalog {
  urls = [
    get_repo_root(),
  ]
}

# configure remote state in bucket
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    project  = local.common_project
    location = "eu"
    bucket   = "academeez-k8s-flux-terragrunt-state"
    prefix   = "${path_relative_to_include()}/tofu.tfstate"
  }
}

# configure common providers
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
%{if length(local.iam.email) > 0}
# impersonate the service account
provider "google" {
  alias = "impersonation"
}

data "google_service_account_access_token" "default" {
  provider               = google.impersonation
  target_service_account = "${local.iam.email}"
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "3600s"
}

provider "google" {
  region  = "${local.region}"
  billing_project = "${local.billing_project}"
  user_project_override = true
  access_token = data.google_service_account_access_token.default.access_token
}

provider "google-beta" {
  region  = "${local.region}"
  billing_project = "${local.billing_project}"
  user_project_override = true
  access_token = data.google_service_account_access_token.default.access_token
}

%{else}
# authenticate as a user for fallback
provider "google" {	
	region  = "${local.region}"
	billing_project = "${local.billing_project}"
	user_project_override = true
}

provider "google-beta" {
  region  = "${local.region}"
  billing_project = "${local.billing_project}"
  user_project_override = true
}
%{endif}



EOF
}
 
