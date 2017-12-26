# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "mokolo"
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
  default = 20
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["sonar"]
}

variable "description" {
  default = "Sonarqube machine"
}
