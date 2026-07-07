# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------


variable "flavor" {
  default = "m3.quad"
}

variable "region" {
  default = "v2"
}

variable "hostname" {
  default = "maji"
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
  default = 100
}

# ----------------------------------------------------------------------------------------------------------------------
# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
# ----------------------------------------------------------------------------------------------------------------------

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["talk"]
}

variable "cf_proxied_cnames" {
  default = ["talk"]
}

variable "acme_challenge_cnames" {
  default = {
    "maji" = "c12635e1-215c-4e4c-b671-2942ca1f4309.acme.openmrs.org"
    "talk" = "b63dfe2d-1007-4afc-a687-25b484b89bd6.acme.openmrs.org"
  }
}

variable "description" {
  default = "Discourse/forum server"
}
