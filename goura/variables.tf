# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "goura"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "prod-tier4"
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
  default = ["sync1", "sync2", "sync3", "sync4", "sync-legacy1", "sync-legacy2"]
}

variable "description" {
  default = "OpenMRS reference application for sync"
}

