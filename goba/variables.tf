# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m3.quad"
}

variable "region" {
  default = "v2"
}

variable "hostname" {
  default = "goba"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "prod-tier3"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 20
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["addons-v2.openmrs.org", "modules-v2.openmrs.org", "atlas-v2.openmrs.org", "implementation-v2.openmrs.org", "quizgrader-v2.openmrs.org", "shields-v2.openmrs.org", "radarproxy-v2.openmrs.org", "sonar-v2.openmrs.org"]
}

variable "description" {
  default = "Internal community tools"
}
