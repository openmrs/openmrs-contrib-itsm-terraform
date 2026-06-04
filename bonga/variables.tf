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
  default = "bonga"
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
  default = ["modules-refapp", "uat-refapp", "uat-refapp2", "qa-refapp", "qa-refapp2", "uat-platform", "test3"]
}

variable "acme_challenge_cnames" {
  default = {
    "bonga"          = "d754e519-a38f-408e-adf7-e7517b9f7e9b.acme.openmrs.org"
    "modules-refapp" = "4ddc5d84-b289-4c89-a15c-21b47fa77ad8.acme.openmrs.org"
    "uat-refapp"     = "ee60bb9f-78df-4bb0-9bf2-1d469aa0b60b.acme.openmrs.org"
    "uat-refapp2"    = "a80ea761-1f77-4861-b90b-38cd5f11fd47.acme.openmrs.org"
    "qa-refapp"      = "fa9c14e1-458f-4398-b667-3e967b6cc047.acme.openmrs.org"
    "qa-refapp2"     = "618eea93-c22e-4163-b297-89c2bec9e38f.acme.openmrs.org"
    "uat-platform"   = "77abcc18-d76f-4648-835d-4d62a3c59ae4.acme.openmrs.org"
    "test3"          = "a5c5f394-7323-481e-8603-8a109f26e7f5.acme.openmrs.org"
  }
}

variable "description" {
  default = "Ephemeral (development and CI) OpenMRS environments"
}
