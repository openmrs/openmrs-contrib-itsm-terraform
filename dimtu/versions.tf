#####################################
# Terraform Providers
#####################################


terraform {

  required_version = "~> 0.13.0"

  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }

    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }

    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }

    aws = {
      source = "hashicorp/aws"
      version = "5.65.0"
      max_retries = 100
    }

    dme = {
      source = "DNSMadeEasy/dme"
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

provider "template" {
}

provider "null" {
}

provider "openstack" {
}