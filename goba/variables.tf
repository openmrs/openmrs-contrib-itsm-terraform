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
  default = "goba"
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
  default = ["addons", "modules", "atlas", "implementation", "quizgrader", "shields", "radarproxy", "trustbot"]
}

variable "acme_challenge_cnames" {
  default = {
    "goba"           = "534c9027-9117-49ee-87c1-cc90bbc02896.acme.openmrs.org"
    "addons"         = "945ff8ca-c8c3-436c-a743-c69cb56d98a8.acme.openmrs.org"
    "modules"        = "cc883ec5-080b-40d7-98a3-fc82fba9855e.acme.openmrs.org"
    "atlas"          = "bc2e3017-e7a7-482f-af74-24a5609afc6c.acme.openmrs.org"
    "implementation" = "b6a661f9-9805-4c3a-a1db-eb9138b89e86.acme.openmrs.org"
    "quizgrader"     = "212335be-15da-4fd2-8c8c-edb3925f4b00.acme.openmrs.org"
    "shields"        = "1c86cee3-4ac6-4e79-95af-fc1835fbf42f.acme.openmrs.org"
  }
}

variable "cf_proxied_cnames" {
  default = ["addons"]
}

variable "description" {
  default = "Internal community tools"
}
