# To be deprecated with Jetstream 1
# ubuntu 16
variable "image" {
  default = "87e08a17-eae2-4ce4-9051-c561d9a54bde"
}

# to be deprecated with Jetstream 1
variable "image_ubuntu_20" {
  default = "46794408-6a80-44b1-bf5a-405127753f43"
}

# Available in Jetstream 2
# Very frequently they deprecate older images, and we need to change this
# terraform is configured to not recreate images if this variable changes
variable "image_ubuntu_22" {
  default = "661fad9f-361f-4c96-804a-e52b32570286"
}

# to be deprecated with Jetstream 1
variable "ssh_key_file" {
  description = "SSH key used to provision VMs"
  default     = "../conf/provisioning/ssh/terraform-api-rsa.key"
}

variable "ssh_key_file_v2" {
  description = "SSH key used to provision VMs"
  default     = "../conf/provisioning/ssh/terraform-api.key"
}

variable "ansible_repo" {
  default = "git@github.com:openmrs/openmrs-contrib-itsmresources.git"
}

# To be deprecated with ubuntu 20/22
variable "ssh_username" {
  default = "root"
}

variable "ssh_username_ubuntu_20" {
  default = "ubuntu"
}

# To be deprecated with ubuntu 20/22
variable "configure_dns" {
  default = true
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

# to be deprecated with Jetstream 1
variable "tacc_url" {
}

# to be deprecated with Jetstream 1
variable "iu_url" {
}

# to be deprecated with Jetstream 1
variable "OS_USERNAME" {
}

# to be deprecated with Jetstream 1
variable "OS_PASSWORD" {
}

# to be deprecated after fully migrating to Jetstream 2
variable "OS_APPLICATION_CREDENTIAL_ID" {
}

# to be deprecated after fully migrating to Jetstream 2
variable "OS_APPLICATION_CREDENTIAL_SECRET" {
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

