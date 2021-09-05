# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

provider "openstack" {
  auth_url = var.iu_url
  alias    = "iu"
  version = "1.43"
}

provider "openstack" {
  auth_url = var.tacc_url
  alias    = "tacc"
  version = "1.43"
}

