variable "ssh_key_file" {
  description = "SSH key used to provision VMs"
  default = "../conf/ssh/terraform-api.key"
}

variable "project_name" {
  description = "Project name in Jetstream"
  default = "TG-ASC170002"
}

variable "domain_dns" {
  description = "DNS domains ID"
  default = {
     "openmrs.org"  = "4712658"
     "openmrs.net"  = ""
     "openmrs.com"  = ""
     "om.rs"        = ""
  }
}
