# ----------------------------------------------------------------------------------------------------------------------
# Security group for aksum.
#
# aksum must not be able to reach other hosts over the project private network. Egress is
# enforced on the Neutron port, so it cannot be overridden from inside the VM. Other hosts
# remain reachable through their public floating IPs.
#
# Replaces the shared ssh-icmp and https groups (use_base_security_groups = false in main.tf)
# because those groups allow all egress, and a port allows anything any of its groups allow.
# Everything lives in a single group to stay within the project's security group quota.
# ----------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

locals {
  # Every IPv4 range except 10.0.0.0/8, which contains the project private subnet
  egress_cidrs = [
    "0.0.0.0/5",
    "8.0.0.0/7",
    "11.0.0.0/8",
    "12.0.0.0/6",
    "16.0.0.0/4",
    "32.0.0.0/3",
    "64.0.0.0/2",
    "128.0.0.0/1",
  ]

  # Neutron's DHCP/DNS server, which the VM uses as its resolver
  private_dns_ip = cidrhost(data.terraform_remote_state.base.outputs.private-subnet-cidr, 2)
}

resource "openstack_networking_secgroup_v2" "aksum_isolated" {
  name                 = "${var.project_name}-aksum-isolated"
  description          = "aksum: ssh, icmp, http/s in; no egress to the private network (terraform)."
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "aksum_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.aksum_isolated.id
}

resource "openstack_networking_secgroup_rule_v2" "aksum_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.aksum_isolated.id
}

resource "openstack_networking_secgroup_rule_v2" "aksum_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.aksum_isolated.id
}

resource "openstack_networking_secgroup_rule_v2" "aksum_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.aksum_isolated.id
}

resource "openstack_networking_secgroup_rule_v2" "aksum_egress" {
  for_each          = toset(local.egress_cidrs)
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = each.value
  security_group_id = openstack_networking_secgroup_v2.aksum_isolated.id
}

resource "openstack_networking_secgroup_rule_v2" "aksum_dns" {
  for_each          = toset(["udp", "tcp"])
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = each.value
  port_range_min    = 53
  port_range_max    = 53
  remote_ip_prefix  = "${local.private_dns_ip}/32"
  security_group_id = openstack_networking_secgroup_v2.aksum_isolated.id
}
