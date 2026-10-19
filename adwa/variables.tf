# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------

variable "flavor" {
  default = "g3.medium"
}

variable "region" {
  default = "v2"
}

variable "hostname" {
  default = "adwa"
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

variable "boot_from_volume" {
  default = true
}

variable "boot_volume_size" {
  default = 60
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
  default = ["chartsearchai"]
}
}

variable "description" {
  default = ""
}
