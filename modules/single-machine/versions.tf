#####################################
# Terraform Providers
#####################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    dme = {
      source = "terraform-providers/dme"
    }
    null = {
      source = "hashicorp/null"
    }
    openstack = {
      source = "terraform-providers/openstack"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}

