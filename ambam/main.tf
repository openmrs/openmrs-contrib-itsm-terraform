# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "ambam.tfstate"
  }
}

# Change to ${var.iu_url} if using iu datacenter
provider "openstack" {
  auth_url = var.iu_url
  version = "1.43"
  project_domain_name = "tacc"
  user_domain_name = "tacc"
  user_name = var.OS_USERNAME
  password = var.OS_PASSWORD
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
module "single-machine" {
  source = "../modules/single-machine"

  # Change values in variables.tf file instead
  flavor                = var.flavor
  hostname              = var.hostname
  region                = var.region
  update_os             = var.update_os
  use_ansible           = var.use_ansible
  ansible_inventory     = var.ansible_inventory
  has_data_volume       = var.has_data_volume
  data_volume_size      = var.data_volume_size
  has_backup            = var.has_backup
  dns_cnames            = var.dns_cnames
  extra_security_groups = [data.terraform_remote_state.base.outputs.secgroup-ldap-name, data.terraform_remote_state.base.outputs.secgroup-database-name]

  # Global variables
  # Don't change values below
  image        = var.image
  project_name = var.project_name
  ssh_username = var.ssh_username
  ssh_key_file = var.ssh_key_file
  domain_dns   = var.domain_dns
  ansible_repo = var.ansible_repo
  dme_apikey    = var.dme_apikey
  dme_secretkey = var.dme_secretkey
}

