# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "worabe.tfstate"
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
  power_state       = "shutoff"

  extra_security_groups = [
    # openstack_compute_secgroup_v2.bamboo-remote-agent.name,
    data.terraform_remote_state.base.outputs.secgroup-database-name,
    openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.name,
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



resource "openstack_networking_secgroup_v2" "bamboo-remote-agent-ssl" {
  name        = "${var.project_name}-bamboo-server-agents-ssl"
  description = "Allow bamboo agents to connect to server using SSL (terraform)."
}


# Using the agents security group didn't seem to do the trick. Using public IPs instead
## yu
resource "openstack_networking_secgroup_rule_v2" "bamboo-remote-agent-ssl-rule-ipv4-yu" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.bamboo_remote_agent_port
  port_range_max    = var.bamboo_remote_agent_port
  remote_ip_prefix  = "149.165.152.37/32"
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.id
}
## xiao
resource "openstack_networking_secgroup_rule_v2" "bamboo-remote-agent-ssl-rule-ipv4-xiao" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.bamboo_remote_agent_port
  port_range_max    = var.bamboo_remote_agent_port
  remote_ip_prefix  = "149.165.154.41/32"
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.id
}
## xindi
resource "openstack_networking_secgroup_rule_v2" "bamboo-remote-agent-ssl-rule-ipv4-xindi" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.bamboo_remote_agent_port
  port_range_max    = var.bamboo_remote_agent_port
  remote_ip_prefix  = "149.165.169.95/32"
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.id
}


## Legacy
# resource "openstack_compute_secgroup_v2" "bamboo-remote-agent" {
#   name        = "${var.project_name}-bamboo-server-agents"
#   description = "Allow bamboo agents to connect to server (terraform)."

#   # xiao jetstream
#   rule {
#     from_port   = var.bamboo_remote_agent_port
#     to_port     = var.bamboo_remote_agent_port
#     ip_protocol = "tcp"
#     cidr        = "149.165.154.41/32"
#   }

#   # yu jetstream
#   rule {
#     from_port   = var.bamboo_remote_agent_port
#     to_port     = var.bamboo_remote_agent_port
#     ip_protocol = "tcp"
#     cidr        = "149.165.152.37/32"
#   }

#   # xindi
#   rule {
#     from_port   = var.bamboo_remote_agent_port
#     to_port     = var.bamboo_remote_agent_port
#     ip_protocol = "tcp"
#     cidr        = "149.165.169.95/32"
#   }
  
# }
