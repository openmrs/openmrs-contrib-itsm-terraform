# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

# To be deprecated
provider "openstack" {
  auth_url = var.iu_url
  alias    = "iu"
  version  = "1.43"
  project_domain_name = "tacc"
  user_domain_name = "tacc"
  user_name = var.OS_USERNAME
  password = var.OS_PASSWORD
}

# to be deprecated
provider "openstack" {
  auth_url = var.tacc_url
  alias    = "tacc"
  version = "1.43"
  project_domain_name = "tacc"
  user_domain_name = "tacc"
  user_name = var.OS_USERNAME
  password = var.OS_PASSWORD
}

provider "openstack" {
  alias    = "v2"
  version = "1.43"
  application_credential_id = var.OS_APPLICATION_CREDENTIAL_ID
  application_credential_secret = var.OS_APPLICATION_CREDENTIAL_SECRET
}

