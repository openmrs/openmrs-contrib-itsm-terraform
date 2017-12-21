# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.small"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "dowa"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "testing"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 30
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["mdsbuilder-new"]
}

variable "description" {
  default = "OpenMRS Platform"
}
