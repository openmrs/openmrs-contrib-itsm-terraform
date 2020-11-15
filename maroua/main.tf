# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "maroua.tfstate"
  }
}

# Change to ${var.tacc_url} if using tacc datacenter
provider "openstack" {
  auth_url = "${var.iu_url}"
}

data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}

# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
module "single-machine" {
  source            = "../modules/single-machine"

  # Change values in variables.tf file instead
  flavor                = "${var.flavor}"
  hostname              = "${var.hostname}"
  region                = "${var.region}"
  update_os             = "${var.update_os}"
  use_ansible           = "${var.use_ansible}"
  ansible_inventory     = "${var.ansible_inventory}"
  has_data_volume       = "${var.has_data_volume}"
  data_volume_size      = "${var.data_volume_size}"
  has_backup            = "${var.has_backup}"
  dns_cnames            = "${var.dns_cnames}"
  extra_security_groups = ["${data.terraform_remote_state.base.secgroup-database-name}"]



  # Global variables
  # Don't change values below
  image             = "${var.image_ubuntu_20}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username_ubuntu_20}"
  ssh_key_file      = "${var.ssh_key_file}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
  configure_dns     = false
}

# this needs to be aname for some reason?
resource "dme_record" "alias-dns" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "tickets"
  type        = "ANAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}
