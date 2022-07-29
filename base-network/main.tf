# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

provider "openstack" {
  version = "1.43"
  region  = "IU"
  application_credential_id = var.OS_APPLICATION_CREDENTIAL_ID
  application_credential_secret = var.OS_APPLICATION_CREDENTIAL_SECRET
}

