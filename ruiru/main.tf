# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "ruiru.tfstate"
  }
}

# Change to ${var.tacc_url} if using tacc datacenter
provider "openstack" {
  auth_url = var.tacc_url
  version  = "1.43"
  project_domain_name = "tacc"
  user_domain_name = "tacc"
  user_name = var.OS_USERNAME
  password = var.OS_PASSWORD
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
  extra_security_groups = [openstack_networking_secgroup_v2.secgroup_ldap.name]

  # Global variables
  # Don't change values below
  image         = var.image
  project_name  = var.project_name
  ssh_username  = var.ssh_username
  ssh_key_file  = var.ssh_key_file
  domain_dns    = var.domain_dns
  ansible_repo  = var.ansible_repo
  dme_apikey    = var.dme_apikey
  dme_secretkey = var.dme_secretkey
}

resource "openstack_networking_secgroup_v2" "secgroup_ldap" {
  name        = "${var.project_name}-ldap-staging-clients"
  description = "Allow ldap staging clients to connect to server (terraform)"
}

# lamu (atlas-stg)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_atlas" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_ip_prefix  = "129.114.18.77/32"
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap.id
}

# gede (Crowd-stg)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_crowd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_ip_prefix  = "129.114.17.122/32"
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap.id
}

# Ruiru (itself)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_dashboard" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_ip_prefix  = "${module.single-machine.address}/32"
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap.id
}

