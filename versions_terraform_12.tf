terraform {
  required_version = ">= 0.12"
}

provider "dme" {
  version = "0.1.3"
  api_key    = var.dme_apikey
  secret_key = var.dme_secretkey
}

provider "aws" {
  version     = "3.57.0"
  max_retries = 100
  skip_get_ec2_platforms = true
}

provider "template" {
  version = "2.2"
}

provider "null" {
  version = "3.0.0"
}

provider "openstack" {
  version = "1.43"
}