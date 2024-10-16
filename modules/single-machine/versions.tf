#####################################
# Terraform Providers
#####################################


terraform {


  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
    }

    dme = {
      source = "dnsmadeeasy/dme"
    }

    aws = {
      source = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 1.0"
}