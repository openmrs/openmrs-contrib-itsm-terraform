terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "watamu.tfstate"
  }
}

module "single-machine" {
  source         = "../modules/single-machine"
  flavor         = "${var.flavor}"
  hostname       = "${var.hostname}"
  project_name   = "${var.project_name}"
  ssh_key_file   = "${var.ssh_key_file}"
  domain_dns     = "${var.domain_dns}"
  has_backup     = false
}

resource "dme_record" "addons" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "addons"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}
