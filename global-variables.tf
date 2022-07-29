# Very frequently they deprecate older images, and we need to change this
# terraform is configured to not recreate images if this variable changes
variable "image_ubuntu_22" {
  default = "661fad9f-361f-4c96-804a-e52b32570286"
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
}

variable "dme_secretkey" {
}

terraform {
  required_version = ">= 0.12"
}

provider "dme" {
  version = "0.1.3"
  api_key    = var.dme_apikey
  secret_key = var.dme_secretkey
}

provider "aws" {
  version     = "3.57.0"
  max_retries = 100
}

provider "template" {
  version = "2.2"
}

provider "null" {
  version = "3.0.0"
}

