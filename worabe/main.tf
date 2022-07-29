# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "worabe.tfstate"
  }
}

provider "openstack" {
  version = "1.43"
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

  extra_security_groups = [
    openstack_compute_secgroup_v2.bamboo-remote-agent.name,
    data.terraform_remote_state.base.outputs.secgroup-database-name,
    openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.name,
  ]



  # Global variables
  # Don't change values below
  image             = "${var.image_ubuntu_22}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username_ubuntu_20}"
  ssh_key_file      = "${var.ssh_key_file_v2}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
  dme_apikey        = var.dme_apikey
  dme_secretkey     = var.dme_secretkey
}



resource "openstack_networking_secgroup_v2" "bamboo-remote-agent-ssl" {
  name        = "${var.project_name}-bamboo-server-agents-ssl"
  description = "Allow bamboo agents to connect to server using SSL (terraform)."
}

resource "openstack_networking_secgroup_rule_v2" "bamboo-remote-agent-ssl-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 54667
  port_range_max    = 54667
  remote_group_id   = data.terraform_remote_state.base.outputs.secgroup-bamboo-remote-agent-id
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.id
}

resource "openstack_compute_secgroup_v2" "bamboo-remote-agent" {
  name        = "${var.project_name}-bamboo-server-agents"
  description = "Allow bamboo agents to connect to server (terraform)."

  # xiao jetstream
  rule {
    from_port   = var.bamboo_remote_agent_port
    to_port     = var.bamboo_remote_agent_port
    ip_protocol = "tcp"
    cidr        = "149.165.154.41/32"
  }

  # xindi jetstream
  rule {
    from_port   = var.bamboo_remote_agent_port
    to_port     = var.bamboo_remote_agent_port
    ip_protocol = "tcp"
    cidr        = "149.165.152.20/32"
  }

  # yu jetstream
  rule {
    from_port   = var.bamboo_remote_agent_port
    to_port     = var.bamboo_remote_agent_port
    ip_protocol = "tcp"
    cidr        = "149.165.152.37/32"
  }
}
