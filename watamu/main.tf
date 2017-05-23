terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "watamu.tfstate"
  }
}

module "single-machine" {
  source            = "../modules/single-machine"
  flavor            = "${var.flavor}"
  hostname          = "${var.hostname}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username}"
  ssh_key_file      = "${var.ssh_key_file}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
  ansible_inventory = "${var.ansible_inventory}"
  has_backup        = false
  use_ansible       = false
}

resource "dme_record" "addons" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "addons"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}
