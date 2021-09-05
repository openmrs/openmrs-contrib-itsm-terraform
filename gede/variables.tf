# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "tacc"
}

variable "hostname" {
  default = "gede"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "staging"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 40
}

variable "has_backup" {
  default = false
}

variable "dns_cnames" {
  default = ["crowd-stg"]
}

variable "power_state" {
  default = "active"
}

variable "description" {
  default = "Crowd/authentication applications staging"
}

