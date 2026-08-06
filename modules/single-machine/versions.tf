#####################################
# Terraform Providers
#####################################


terraform {


  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
    }

    aws = {
      source = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 1.5"
}
