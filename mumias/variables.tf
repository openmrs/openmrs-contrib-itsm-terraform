# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "tacc"
}

variable "hostname" {
  default = "mumias"
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
  default = false
}

variable "data_volume_size" {
  default = 60
}

variable "has_backup" {
  default = false
}

variable "dns_cnames" {
  default = ["wiki-stg", "issues-stg"]
}

variable "power_state" {
  default = "shutoff"
}

variable "description" {
  default = "Issue tracker and wiki staging machine"
}
