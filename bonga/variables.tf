# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m3.medium"
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
  default = false
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
  default = ["modules-refapp-v2", "uat-refapp-v2", "qa-refapp-v2", "uat-platform-v2", "dev3-v2"]
}

variable "description" {
  default = "Ephemeral (development and CI) OpenMRS environments"
}
