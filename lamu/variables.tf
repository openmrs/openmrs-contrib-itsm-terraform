# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.small"
}

variable "region" {
  default = "tacc"
}

variable "hostname" {
  default = "lamu"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false  # VM created before this integration
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
  default = ["addons-stg", "modules-stg"]
}

variable "description" {
  default = ""
}
