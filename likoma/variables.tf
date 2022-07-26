# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "likoma"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "prod-tier1"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 60
}

# backups straight from discourse
# but keeping it in case it's needed
variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["talk-v1"]
}

variable "description" {
  default = "Discourse/forum server"
}

