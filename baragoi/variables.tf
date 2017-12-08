# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.small"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "baragoi"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "production"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 60
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["id-new"]
}

variable "description" {
  default = "ID dashboard"
}
