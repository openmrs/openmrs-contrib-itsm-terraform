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
  default = "gode"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = true
}

variable "ansible_inventory" {
  default = "prod-tier4"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 20
}

# ----------------------------------------------------------------------------------------------------------------------
# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
# ----------------------------------------------------------------------------------------------------------------------

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["addons-stg", "atlas-stg", "sso-stg", "ldap-stg", "modules-stg"]
}

variable "description" {
  default = "Internal community tools (staging & QA)"
}
