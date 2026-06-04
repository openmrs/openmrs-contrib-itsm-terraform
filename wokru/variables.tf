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
  default = "wokru"
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
  default = true
}

variable "dns_cnames" {
  default = ["sec3"]
}

variable "acme_challenge_cnames" {
  default = {
    "wokru" = "c6d7c5b3-fd4d-4dec-9391-34f0aa6f8e60.acme.openmrs.org"
    "sec3"  = "b682f7ff-3633-4e3e-9de4-7d23eef502e1.acme.openmrs.org"
  }
}

variable "description" {
  default = "Server setup with O3 for Qualys scan"
}
