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
  default = "bele"
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
  default = 80
}

# ----------------------------------------------------------------------------------------------------------------------
# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
# ----------------------------------------------------------------------------------------------------------------------

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["demo", "mdsbuilder", "o2", "o3", "cieladmin", "chartsearchai"]
}

variable "acme_challenge_cnames" {
  default = {
    "bele"          = "d0985737-896e-40c3-8e1f-cb74ef033265.acme.openmrs.org"
    "cieladmin"     = "945ff8ca-c8c3-436c-a743-c69cb56d98a8.acme.openmrs.org"
    "demo"          = "79a5eaae-5dac-451e-bad1-7dc290684855.acme.openmrs.org"
    "mdsbuilder"    = "20129a1f-3ec8-4414-a19b-f48268b508b6.acme.openmrs.org"
    "o2"            = "6e03a64d-11a2-4235-8d09-5c3f8037d0b6.acme.openmrs.org"
    "o3"            = "122fa16c-fa93-4752-83b4-21544567906c.acme.openmrs.org"
    "chartsearchai" = "b4e619c0-b93d-4dc7-98bf-8bb8fc31f683.acme.openmrs.org"
  }
}

variable "cf_proxied_cnames" {
  default = ["demo", "mdsbuilder", "o2", "o3", "cieladmin", "chartsearchai"]
}

variable "description" {
  default = "Stable OpenMRS environments"
}
