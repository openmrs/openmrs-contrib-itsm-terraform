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
  default = "aksum"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "prod-tier3"
}

variable "boot_from_volume" {
  default = true
}

variable "boot_volume_size" {
  default = 120
}

variable "has_data_volume" {
  default = false
}

variable "data_volume_size" {
  default = 10
}

# ----------------------------------------------------------------------------------------------------------------------
# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
# ----------------------------------------------------------------------------------------------------------------------

variable "has_backup" {
  default = false
}

variable "dns_cnames" {
  default = ["hermes"]
}

variable "description" {
  default = "Hermes Agent host for OpenMRS"
}
