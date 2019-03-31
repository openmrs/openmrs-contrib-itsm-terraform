# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "tacc"
}

variable "hostname" {
  default = "chitipa"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
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
  default = ["database-stg"]
}

variable "description" {
  default = "Database staging"
}
