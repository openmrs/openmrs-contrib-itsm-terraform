# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "sawla.tfstate"
  }
}

provider "openstack" {
  version = "1.43"
  application_credential_id = var.OS_APPLICATION_CREDENTIAL_ID
  application_credential_secret = var.OS_APPLICATION_CREDENTIAL_SECRET
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
  source            = "../modules/single-machine"

  # Change values in variables.tf file instead
  flavor            = "${var.flavor}"
  hostname          = "${var.hostname}"
  region            = "${var.region}"
  update_os         = "${var.update_os}"
  use_ansible       = "${var.use_ansible}"
  ansible_inventory = "${var.ansible_inventory}"
  has_data_volume   = "${var.has_data_volume}"
  data_volume_size  = "${var.data_volume_size}"
  has_backup        = "${var.has_backup}"
  dns_cnames        = "${var.dns_cnames}"
  allow_web         = false
  has_private_dns   = true

  extra_security_groups = [openstack_networking_secgroup_v2.secgroup_database.name]


  # Global variables
  # Don't change values below
  image             = "${var.image_ubuntu_22}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username_ubuntu_20}"
  ssh_key_file      = "${var.ssh_key_file_v2}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
  configure_dns     = false
  dme_apikey        = var.dme_apikey
  dme_secretkey     = var.dme_secretkey
}


resource "dme_dns_record" "private-dns" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "db-internal"
  type      = "CNAME"
  value     = module.single-machine.private-dns
  ttl       = 300
}

resource "openstack_networking_secgroup_v2" "secgroup_database" {
  name        = "${var.project_name}-database-server"
  description = "Allow database clients to connect to server (terraform)"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_database" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_group_id   = data.terraform_remote_state.base.outputs.secgroup-database-id
  security_group_id = openstack_networking_secgroup_v2.secgroup_database.id
}
