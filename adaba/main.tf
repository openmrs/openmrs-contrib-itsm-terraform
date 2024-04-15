# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "adaba.tfstate"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------

module "single-machine" {
  source            = "../modules/single-machine"

  ################################################
  # Change values in variables.tf file instead
  ################################################
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
    openstack_networking_secgroup_v2.secgroup_ldap.name,
    openstack_networking_secgroup_v2.secgroup_smtp.name,
    data.terraform_remote_state.base.outputs.secgroup-database-name
  ]

  # ----------------------------------------------------------------------------------------------------------------------
  # Global variables
  # Don't change values below
  # ----------------------------------------------------------------------------------------------------------------------

  image             = "${var.image_ubuntu_22}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username_ubuntu_20}"
  ssh_key_file      = "${var.ssh_key_file_v2}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
}

# ----------------------------------------------------------------------------------------------------------------------
# DNS RECORDS
# ----------------------------------------------------------------------------------------------------------------------

resource "dme_dns_record" "mx_id" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "id"
  type        = "MX"
  mx_level    = "10"
  value       = "smtp"
  ttl         = 300
}

resource "dme_dns_record" "a_smtp" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "smtp"
  type        = "A"
  value       = module.single-machine.address
  ttl         = 300
}

resource "dme_dns_record" "a_id" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "id"
  type        = "A"
  value       = module.single-machine.address
  ttl         = 300
}

# ----------------------------------------------------------------------------------------------------------------------
# Temporary subdomain for Keycloak until ID is switched off
# ----------------------------------------------------------------------------------------------------------------------

resource "dme_dns_record" "a_id_new" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "id-new"
  type        = "A"
  value       = module.single-machine.address
  ttl         = 300
}

# ----------------------------------------------------------------------------------------------------------------------
# Domain verification for Atlassian outgoing e-mails
# ----------------------------------------------------------------------------------------------------------------------

resource "dme_dns_record" "txt_atlassian" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = ""
  type        = "TXT"
  value       = "atlassian-sending-domain-verification=0fdf1857-bba2-4642-ad65-82e86115de7b"
  ttl         = 300
}
resource "dme_dns_record" "cname_active_atlassian" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "atlassian-6d771e._domainkey"
  type        = "CNAME"
  value       = "atlassian-6d771e.dkim.atlassian.net."
  ttl         = 300
}
resource "dme_dns_record" "cname_fallback_atlassian" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "atlassian-7cbba2._domainkey"
  type        = "CNAME"
  value       = "atlassian-7cbba2.dkim.atlassian.net."
  ttl         = 300
}
resource "dme_dns_record" "cname_bounce_atlassian" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = "atlassian-bounces"
  type        = "CNAME"
  value       = "bounces.mail-us.atlassian.net."
  ttl         = 300
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

resource "openstack_networking_secgroup_v2" "secgroup_ldap" {
  name        = "${var.project_name}-ldap-clients"
  description = "Allow ldap clients to connect to server (terraform)"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ldaps" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_group_id   = data.terraform_remote_state.base.outputs.secgroup-ldap-id
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap.id
}

# ----------------------------------------------------------------------------------------------------------------------
# goba (atlas) SEC GROUP
# ---------------------------------------------------------------------------------------------------------------------- 

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ldaps_atlas" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_ip_prefix  = "149.165.154.224/32"
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap.id
}

# ----------------------------------------------------------------------------------------------------------------------
# adaba (id and crowd, using public IP)
# ----------------------------------------------------------------------------------------------------------------------

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ldaps_id" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 636
  port_range_max    = 636
  remote_ip_prefix  = "${module.single-machine.address}/32"
  security_group_id = openstack_networking_secgroup_v2.secgroup_ldap.id
}

resource "openstack_networking_secgroup_v2" "secgroup_smtp" {
  name        = "${var.project_name}-smtp-clients"
  description = "Allow smtp clients to connect to server (terraform)"
}

# ----------------------------------------------------------------------------------------------------------------------
# Allow all smtp and smtps access
# ----------------------------------------------------------------------------------------------------------------------

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_smtps_id" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 587
  port_range_max    = 587
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_smtp.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_smtp_id" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 25
  port_range_max    = 25
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_smtp.id
}