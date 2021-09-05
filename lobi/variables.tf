# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "lobi"
}

variable "update_os" {
  default = true
}

variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "prod-tier2"
}

variable "has_data_volume" {
  default = true
}

variable "data_volume_size" {
  default = 80
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = []
}

output "power_state" {
  value = module.single-machine.power_state
}

variable "bamboo_remote_agent_port" {
  default = "54663"
}

variable "description" {
  default = "CI server"
}

