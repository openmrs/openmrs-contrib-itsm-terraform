terraform {
  required_providers {
    dme = {
      source = "dnsmadeeasy/dme"
    }
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
  required_version = ">= 0.13"
}
