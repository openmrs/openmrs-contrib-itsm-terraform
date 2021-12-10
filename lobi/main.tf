# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "lobi.tfstate"
  }
}

# Change to ${var.tacc_url} if using tacc datacenter
provider "openstack" {
  auth_url = var.iu_url
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
  extra_security_groups = [
    openstack_compute_secgroup_v2.bamboo-remote-agent.name,
    data.terraform_remote_state.base.outputs.secgroup-database-name,
    openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.name,
  ]

  has_private_dns = true

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
  remote_group_id   = data.terraform_remote_state.base.outputs.secgroup-bamboo-remote-agent-id-iu
  security_group_id = openstack_networking_secgroup_v2.bamboo-remote-agent-ssl.id
}

resource "openstack_compute_secgroup_v2" "bamboo-remote-agent" {
  name        = "${var.project_name}-bamboo-server-agents"
  description = "Allow bamboo agents to connect to server (terraform)."

  # Bamboo agents Jetstream in IU (works with the private IP only)
  rule {
    from_port     = var.bamboo_remote_agent_port
    to_port       = var.bamboo_remote_agent_port
    ip_protocol   = "tcp"
    from_group_id = data.terraform_remote_state.base.outputs.secgroup-bamboo-remote-agent-id-iu
  }

  ##### after migration, the agents shoud connect using the private DNS - ITSM-4090
  # yak jetstream
  rule {
    from_port   = var.bamboo_remote_agent_port
    to_port     = var.bamboo_remote_agent_port
    ip_protocol = "tcp"
    cidr        = "149.165.168.253/32"
  }

  # yokobue jetstream
  rule {
    from_port   = var.bamboo_remote_agent_port
    to_port     = var.bamboo_remote_agent_port
    ip_protocol = "tcp"
    cidr        = "149.165.170.92/32"
  }

  # yue jetstream
  rule {
    from_port   = var.bamboo_remote_agent_port
    to_port     = var.bamboo_remote_agent_port
    ip_protocol = "tcp"
    cidr        = "149.165.168.182/32"
  }
}

resource "dme_dns_record" "alias-dns" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "ci"
  type      = "ANAME"
  value     = var.hostname
  ttl       = 3600
}

resource "dme_dns_record" "private-dns" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "ci-internal"
  type      = "CNAME"
  value     = module.single-machine.private-dns
  ttl       = 300
}

