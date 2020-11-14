variable "image" {
  default = "46794408-6a80-44b1-bf5a-405127753f43"
}

variable "ssh_key_file" {
  description = "SSH key used to provision VMs"
  default = "../conf/provisioning/ssh/terraform-api.key"
}

variable "ansible_repo" {
  default = "git@github.com:openmrs/openmrs-contrib-itsmresources.git"
}

variable "ssh_username" {
  default = "ubuntu"
}

variable "project_name" {
  description = "Project name in Jetstream"
  default = "TG-ASC170002"
}

variable "domain_dns" {
  description = "DNS domains ID"
  default = {
     "openmrs.org"  = "4712658"
     "openmrs.net"  = "4714812"
     "openmrs.com"  = "4714813"
     "om.rs"        = "4714810"
  }
}

variable "main_domain_dns" {
  default = "openmrs.org"
}

variable "tacc_url" { }
variable "iu_url" { }
