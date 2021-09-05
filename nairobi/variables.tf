# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.large"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "nairobi"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "prod-tier3"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 60
}

variable "has_backup" {
  default = true
}

# using openconceptlab.org instead, manually
variable "dns_cnames" {
  default = []
}

variable "description" {
  default = "Openconcept lab"
}

