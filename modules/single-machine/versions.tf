#####################################
# Terraform Providers
#####################################


terraform {


  required_providers {

    openstack = {
      source = "terraform-provider-openstack/openstack"
    }

    dme = {
      source = "DNSMadeEasy/dme"
    } 

  }
}