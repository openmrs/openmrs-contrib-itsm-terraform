# ----------------------------------------------------------------------------------------------------------------------
# Security groups for the acme-dns host.
#
#   * Public DNS  — acme-dns is authoritative for acme.openmrs.org and must answer DNS-01
#                   challenge lookups from Let's Encrypt's resolvers, so 53/udp+tcp is open
#                   to the world.
#   * Private API — registration and TXT-update calls carry account credentials and must
#                   NOT be public. The HTTP API is reachable only from the project private
#                   subnet; cert hosts reach it over the private network by chiro's fixed IP.
#
# Attached to the VM via the module's extra_security_groups; allow_web is disabled in
# main.tf so the public 80/443 web group is NOT attached.
# ----------------------------------------------------------------------------------------------------------------------

# Read the private subnet CIDR from base-network rather than hardcoding it.
data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

resource "openstack_networking_secgroup_v2" "acme_dns_public" {
  name        = "${var.project_name}-acme-dns-public"
  description = "acme-dns: public DNS (53 udp/tcp) (terraform)."
}

resource "openstack_networking_secgroup_rule_v2" "acme_dns_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 53
  port_range_max    = 53
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.acme_dns_public.id
}

resource "openstack_networking_secgroup_rule_v2" "acme_dns_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 53
  port_range_max    = 53
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.acme_dns_public.id
}

resource "openstack_networking_secgroup_v2" "acme_dns_api" {
  name        = "${var.project_name}-acme-dns-api"
  description = "acme-dns: HTTP API from the private subnet only (terraform)."
}

resource "openstack_networking_secgroup_rule_v2" "acme_dns_api_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.acme_dns_api_port
  port_range_max    = var.acme_dns_api_port
  remote_ip_prefix  = data.terraform_remote_state.base.outputs.private-subnet-cidr
  security_group_id = openstack_networking_secgroup_v2.acme_dns_api.id
}
