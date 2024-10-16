#####################################
# Terraform Providers
#####################################


terraform {

  required_version = ">= 1.0"

  required_providers {

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }

    dme = {
      source  = "dnsmadeeasy/dme"
      version = "1.0.6"
    }

  }
}

provider "dme" {
  api_key    = var.dme_apikey
  secret_key = var.dme_secretkey
}

provider "aws" {
  max_retries = 100
}

provider "null" {
}

provider "openstack" {
}