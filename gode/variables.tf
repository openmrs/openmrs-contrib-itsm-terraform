# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m3.small"
}

variable "region" {
  default = "v2"
}

variable "hostname" {
  default = "gode"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "prod-tier4"
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
  default = ["addons-stg-v2.openmrs.org", "modules-stg-v2.openmrs.org", "atlas-stg-v2.openmrs.org"]
}

variable "description" {
  default = "Internal community tools (staging & QA)"
}
