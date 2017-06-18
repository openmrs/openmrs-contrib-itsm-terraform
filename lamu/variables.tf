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
  default = "staging"
}

variable "has_data_volume" {
  default = false
}

variable "data_volume_size" {
  default = 10
}

variable "has_backup" {
  default = false
}
