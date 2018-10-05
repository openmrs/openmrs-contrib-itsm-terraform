# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.tiny"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "campo"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "prod-tier1"
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

variable "dns_cnames" {
  default = ["mavenrepo", "mavenrepo-redirect", "help"]
}

variable "description" {
  default = "HTTP redirects"
}
