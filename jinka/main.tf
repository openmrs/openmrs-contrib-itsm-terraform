# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "jinka.tfstate"
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


  # Global variables
  # Don't change values below
  image             = "${var.image_ubuntu_22}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username_ubuntu_20}"
  ssh_key_file      = "${var.ssh_key_file_v2}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
}

resource "dme_dns_record" "short-dns" {
  domain_id = var.domain_dns[var.dns_domain]
  name      = ""
  type      = "ANAME"
  value     = "${var.hostname}.${var.main_domain_dns}."
  ttl       = 300
}

resource "dme_dns_record" "short-dns-wildcard" {
  domain_id = var.domain_dns[var.dns_domain]
  name      = "*"
  type      = "ANAME"
  value     = "${var.hostname}.${var.main_domain_dns}."
  ttl       = 300
}

# Terraform provider bug doesn't allow to update APEX
resource "dme_dns_record" "apex" {
  domain_id   = var.domain_dns["openmrs.org"]
  name        = ""
  type        = "A"
  value       = module.single-machine.address
  ttl         = 300
}

resource "dme_dns_record" "servicedesk-cname" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "servicedesk.jira"
  type      = "CNAME"
  value     = "servicedesk-jira-openmrs--bc43f69c-56bf-40be-adb3-601e89fad51a.saas.atlassian.com."
  ttl       = 300
}

resource "dme_dns_record" "servicedesk-cname2" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "_75f1ffb08e1ad4e23e1a159cb1418945.servicedesk.jira"
  type      = "CNAME"
  value     = "servicedesk-jira-openmrs--bc43f69c-56bf-40be-adb3-601e89fad51a.ssl.atlassian.com."
  ttl       = 300
}
