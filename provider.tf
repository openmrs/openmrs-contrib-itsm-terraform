#####################################
# Terraform Providers
#####################################

# terraform {

#   required_version = "~> 0.13.0"

#   required_providers {

#     openstack = {
#       source = "terraform-provider-openstack/openstack"
#       # version = "~> 1.53.0"
#     }

#     null = {
#       source = "hashicorp/null"
#       # version = "~> 3.2.2"
#     }

#     template = {
#       source = "hashicorp/template"
#       # version = "~> 2.2.0"
#     }

#     aws = {
#       source = "hashicorp/aws"
#       # version = "~> 5.55.0"
#       max_retries = 100
#     }

#     dme = {
#       source = "DNSMadeEasy/dme"
#       # version = "~> 1.0.6"
#     }

#   }

# }


terraform {
  required_version = "~> 0.13.0"
  required_providers {
    dme = {
      version = "0.1.3"
      api_key    = var.dme_apikey
      secret_key = var.dme_secretkey
    }
    aws = {
      version     = "3.57.0"
    }
    template = {
      version = "2.2"
    }
    null = {
      version = "3.0.0"
      max_retries = 100
    }
    openstack = {
      version = "1.43"
    }
  }
}

provider "dme" {
  # dme Api key
  api_key    = var.dme_apikey
  # dme secret key
  secret_key = var.dme_secretkey
}