# Very frequently they deprecate older images, and we need to change this
# terraform is configured to not recreate images if this variable changes
variable "image_ubuntu_22" {
  default = "26459ddd-3ad4-42c0-9255-fc5e682bb037"
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

# ----------------------------------------------------------------------------------------------------------------------
# TERRAFORM VERSIONS AND PROVIDER DETAILS
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2.2"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
      max_retries = 100
    }
    dme = {
      source = "DNSMadeEasy/dme"
      version = "~> 1.0.6"
      api_key    = var.dme_apikey
      secret_key = var.dme_secretkey
    }
  }
}
