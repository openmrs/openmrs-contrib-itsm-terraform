# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository

variable "flavor" {
  default = "m1.medium"
}

variable "region" {
  default = "iu"
}

variable "hostname" {
  default = "salima"
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

# This was actually increased manually
# as using terraform would destroy the volume. 
# https://issues.openmrs.org/browse/ITSM-4211?focusedCommentId=272011&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-272011
variable "data_volume_size" {
  default = 80
}

variable "has_backup" {
  default = true
}

variable "dns_cnames" {
  default = ["database"]
}

variable "description" {
  default = "Database"
}

