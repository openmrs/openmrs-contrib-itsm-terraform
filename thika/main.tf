# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "thika.tfstate"
  }
}

provider "openstack" {
  auth_url = "${var.tacc_url}"
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
  image             = "${var.image}"
  hostname          = "${var.hostname}"
  project_name      = "${var.project_name}"
  ssh_username      = "${var.ssh_username}"
  ssh_key_file      = "${var.ssh_key_file}"
  domain_dns        = "${var.domain_dns}"
  ansible_repo      = "${var.ansible_repo}"
  ansible_inventory = "${var.ansible_inventory}"
  region            = "tacc"
  has_backup        = false
  use_ansible       = true
}

resource "dme_record" "quizgrader" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "quizgrader"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}
