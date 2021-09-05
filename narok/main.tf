# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "narok.tfstate"
  }
}

# Change to ${var.iu_url} if using iu datacenter
provider "openstack" {
  auth_url = var.iu_url
  version = "1.43"
}

provider "dme" {
    version = "0.1.3"
    api_key    = var.dme_apikey
    secret_key = var.dme_secretkey
}

provider "aws" {
    version = "3.57.0"
    max_retries = 100
}

provider "template" {
    version = "2.2"
}

provider "null" {
    version = "3.0.0"
}

# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
module "single-machine" {
  source = "../modules/single-machine"

  # Change values in variables.tf file instead
  flavor            = var.flavor
  hostname          = var.hostname
  region            = var.region
  update_os         = var.update_os
  use_ansible       = var.use_ansible
  ansible_inventory = var.ansible_inventory
  has_data_volume   = var.has_data_volume
  data_volume_size  = var.data_volume_size
  has_backup        = var.has_backup
  dns_cnames        = var.dns_cnames

  # Global variables
  # Don't change values below
  image        = var.image
  project_name = var.project_name
  ssh_username = var.ssh_username
  ssh_key_file = var.ssh_key_file
  domain_dns   = var.domain_dns
  ansible_repo = var.ansible_repo
}

