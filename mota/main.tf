# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "mota.tfstate"
  }
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------

module "single-machine" {
  source = "../modules/single-machine"

  ################################################
  # Change values in variables.tf file instead
  ################################################
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

  extra_security_groups = [
    data.terraform_remote_state.base.outputs.secgroup-database-name,
    openstack_networking_secgroup_v2.bamboo-remote-stg-agent.name,
  ]


  # ----------------------------------------------------------------------------------------------------------------------
  # Global variables
  # Don't change values below
  # ----------------------------------------------------------------------------------------------------------------------

  image        = var.image_ubuntu_22
  project_name = var.project_name
  ssh_username = var.ssh_username_ubuntu_20
  ssh_key_file = var.ssh_key_file_v2
  domain_dns   = var.domain_dns
  ansible_repo = var.ansible_repo
}

# Using the agents security group didn't seem to do the trick. Using public IPs instead
resource "openstack_networking_secgroup_v2" "bamboo-remote-stg-agent" {
  name        = "${var.project_name}-stg-bamboo-server-agents"
  description = "Allow bamboo agents to connect to server (terraform)."
}

# yu jetstream
resource "openstack_networking_secgroup_rule_v2" "bamboo-remote-agent-ssl-rule-ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.bamboo_remote_agent_port
  port_range_max    = var.bamboo_remote_agent_port
  remote_ip_prefix  = "149.165.152.37/32"
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-stg-agent.id
}


# ploong jetstream
resource "openstack_networking_secgroup_rule_v2" "bamboo-remote-ploong-ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.bamboo_remote_agent_port
  port_range_max    = var.bamboo_remote_agent_port
  remote_ip_prefix  = "149.165.155.237/32"
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-stg-agent.id
}