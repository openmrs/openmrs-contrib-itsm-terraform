# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "gode.tfstate"
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

  extra_security_groups = [
    openstack_networking_secgroup_v2.secgroup_ldap_stg.name,
    openstack_networking_secgroup_v2.secgroup_smtp_stg.name
  ]


  # Global variables
  # Don't change values below
  image             = "${var.image_ubuntu_22}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username_ubuntu_20}"
  ssh_key_file      = "${var.ssh_key_file_v2}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
}

resource "openstack_networking_secgroup_v2" "secgroup_ldap_stg" {
  name        = "${var.project_name}-ldap-stg-clients"
  description = "Allow ldap-stg clients to connect to server (terraform)"
}

# gode
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ldap_stg_id" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_ip_prefix  = "${module.single-machine.address}/32"
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap_stg.id
}

resource "openstack_networking_secgroup_v2" "secgroup_smtp_stg" {
  name        = "${var.project_name}-smtp-stg-clients"
  description = "Allow smtp-stg clients to connect to server (terraform)"
}

# allow all smtp access
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_smtp_stg_id" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 587
  port_range_max    = 587
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_smtp_stg.id
}