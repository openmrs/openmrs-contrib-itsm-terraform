# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#     }
#     dme = {
#       source = "terraform-providers/dme"
#     }
#     null = {
#       source = "hashicorp/null"
#     }
#     openstack = {
#       source = "terraform-providers/openstack"
#     }
#     template = {
#       source = "hashicorp/template"
#     }
#   }
#   required_version = ">= 0.13"
# }

#####################################
# Terraform Providers
#####################################

terraform {

  required_version = "~> 0.13.0"

  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
      # version = "~> 1.53.0"
    }

    null = {
      source = "hashicorp/null"
      # version = "~> 3.2.2"
    }

    template = {
      source = "hashicorp/template"
      # version = "~> 2.2.0"
    }

    aws = {
      source = "hashicorp/aws"
      # version = "~> 5.0"
      max_retries = 100
    }

    dme = {
      source = "DNSMadeEasy/dme"
      # version = "~> 1.0.6"
    }

  }

}

provider "dme" {
  # dme Api key
  api_key    = var.dme_apikey
  # dme secret key
  secret_key = var.dme_secretkey
}
