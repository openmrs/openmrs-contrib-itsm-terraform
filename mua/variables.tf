# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "mua"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "prod-tier2"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 40
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["site", "www", "shortener", "beta", "site-legacy"]
}

variable "dns_domain" {
  default = "om.rs"
}

variable "description" {
  default = "OpenMRS community applications"
}

