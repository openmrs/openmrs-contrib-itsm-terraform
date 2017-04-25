terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "watamu.tfstate"
  }
}

module "single-machine" {
  source         = "../modules/single-machine"
  flavor         = "${var.flavor}"
  hostname       = "watamu"
  project_name   = "${var.project_name}"
  ssh_key_file   = "${var.ssh_key_file}"
  domain_dns     = "${var.domain_dns}"
}
