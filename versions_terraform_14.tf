#####################################
# Terraform Providers
#####################################


terraform {

  required_version = ">= 1.5"

  required_providers {

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.3.2"
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

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
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