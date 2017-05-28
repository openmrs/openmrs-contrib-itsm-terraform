# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "garissa.tfstate"
  }
}

# any resources from the base stack
data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}

module "single-machine" {
  source            = "../modules/single-machine"
  flavor            = "${var.flavor}"
  image             = "${var.override-image}"
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

resource "dme_record" "demo" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "demo"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}

resource "dme_record" "modules" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "modules-refapp"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}

resource "dme_record" "uat" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "uat-refapp"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}

resource "dme_record" "qa" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "qa-refapp"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}
