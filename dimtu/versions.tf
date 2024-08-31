#####################################
# Terraform Providers
#####################################


terraform {

  required_version = "~> 0.13.0"

  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.43"
    }

    null = {
      source = "hashicorp/null"
      version = "3.0.0"
    }

    template = {
      source = "hashicorp/template"
      version = "2.2"
    }

    aws = {
      source = "hashicorp/aws"
      version = "3.57.0"
      max_retries = 100
    }

    dme = {
      source = "DNSMadeEasy/dme"
      version = "0.1.3"
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

provider "template" {
}

provider "null" {
}

provider "openstack" {
}