# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------


variable "flavor" {
  default = "m3.tiny"
}

variable "region" {
  default = "v2"
}

variable "hostname" {
  default = "chiro"
}

variable "update_os" {
  default = true
}

# acme-dns is configured by the `custom_roles/acme-dns` role in the itsmresources repo.
# Leave Ansible provisioning OFF until that role and the [acme-dns] inventory group exist,
# then flip to true (or run the playbook manually). See acme-dns-dns01-terraform-brief.md.
variable "use_ansible" {
  default = false
}

variable "ansible_inventory" {
  default = "prod-tier3"
}

variable "has_data_volume" {
  default = false
}

variable "data_volume_size" {
  default = 10
}

variable "has_backup" {
  default = false
}

variable "dns_cnames" {
  default = []
}

# Publish chiro-internal.openmrs.org (A -> private 10.0.2.x IP), matching the db-internal
# pattern. Cert hosts use this stable name as the acme-dns API endpoint instead of a raw IP,
# so a VM rebuild that changes the fixed IP doesn't require editing every host's config.
variable "has_private_dns" {
  default = true
}

# Plain-HTTP port for the acme-dns API. Private-only (see security group), so no TLS is
# needed over the private network. The allowed source CIDR is read from base-network's
# `private-subnet-cidr` output (see security-groups.tf), not a variable.
variable "acme_dns_api_port" {
  default = 8080
}

variable "description" {
  default = "acme-dns server for DNS-01 ACME challenges"
}
