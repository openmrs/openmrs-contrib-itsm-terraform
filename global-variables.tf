# ----------------------------------------------------------------------------------------------------------------------
# Very frequently they deprecate older images, and we need to change this
# terraform is configured to not recreate images if this variable changes
# ----------------------------------------------------------------------------------------------------------------------

variable "image_ubuntu_22" {
  default = "efec0d7e-470f-4a14-93d4-a740b0bc4759"
}

variable "ssh_key_file_v2" {
  description = "SSH key used to provision VMs"
  default     = "../conf/provisioning/ssh/terraform-api.key"
}

variable "ansible_repo" {
  default = "git@github.com:openmrs/openmrs-contrib-itsmresources.git"
}

variable "ssh_username_ubuntu_20" {
  default = "ubuntu"
}

variable "project_name" {
  description = "Project name in Jetstream"
  default     = "TG-ASC170002"
}

variable "domain_dns" {
  description = "DNS domains ID"
  default = {
    "openmrs.org" = "4712658"
    "openmrs.net" = "4714812"
    "openmrs.com" = "4714813"
    "om.rs"       = "4714810"
  }
}

variable "main_domain_dns" {
  default = "openmrs.org"
}

variable "dme_apikey" {
  default = ""
}

variable "dme_secretkey" {
  default = ""
}
