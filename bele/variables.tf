# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

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
  default = 20
}

# If enabling this, make sure to uncomment the two outputs related to backup
# Those outputs will be copied over manually to ansible, and stored encrypted
variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["demo-v2", "mdsbuilder-v2", "o3-v2", "openconceptlab"]
}

output "dns_manual_entries" {
  value = []
}

variable "description" {
  default = "Stable OpenMRS environments"
}