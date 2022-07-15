# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

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
  default = 20
}

# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["modules-refapp-v2", "uat-refapp-v2", "qa-refapp-v2", "uat-platform-v2", "dev3-v2", "openconceptlab-demo", "openconceptlab-staging", "openconceptlab-qa"]
}

output "dns_manual_entries" {
  value = []
}

variable "description" {
  default = "Ephemeral (development and CI) OpenMRS environments"
}
