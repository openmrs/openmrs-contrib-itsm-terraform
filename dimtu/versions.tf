#####################################
# Terraform Providers
#####################################


terraform {

  required_version = "~> 0.13.0"


  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
      # version = "~> 1.43"
    }

    null = {
      source = "hashicorp/null"
      # version = "~> 3.0.0"
    }

    template = {
      source = "hashicorp/template"
      # version = "~> 2.2"
    }

    aws = {
      source = "hashicorp/aws"
      # version = "~> 3.57.0"
      max_retries = 100
    }

    dme = {
      source = "terraform-providers/dme"
      # version = "~> "0.1.3""
    } 

  }



}

provider "dme" {
  # dme Api key
  api_key    = "apikey"
  # dme secret key
  secret_key = "secretkey"
  insecure  = true
  proxyurl = "https://proxy_server:proxy_port"
}


# provider "dme" {
#   version = "0.1.3"
#   api_key    = var.dme_apikey
#   secret_key = var.dme_secretkey
# }

# provider "aws" {
#   version     = "3.57.0"
#   max_retries = 100
#   skip_get_ec2_platforms = true
# }

# provider "template" {
#   version = "2.2"
# }

# provider "null" {
#   version = "3.0.0"
# }

# provider "openstack" {
#   version = "1.43"
# }