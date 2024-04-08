# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------

variable "flavor" {
  default = "m3.small"
}

variable "region" {
  default = "v2"
}

variable "hostname" {
  default = "xindi"
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


# ----------------------------------------------------------------------------------------------------------------------
# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
# ----------------------------------------------------------------------------------------------------------------------

variable "has_backup" {
  default = false
}

variable "dns_cnames" {
  default = []
}

variable "description" {
  default = "Bamboo agent"
}
