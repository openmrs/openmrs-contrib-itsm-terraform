resource "dme_dns_record" "hostname" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = var.hostname
  type      = "A"
  value     = openstack_networking_floatingip_v2.ip.address
  ttl       = var.default_dns_ttl
}

resource "dme_dns_record" "private_hostname" {
  count     = var.has_private_dns ? 1 : 0
  domain_id = var.domain_dns["openmrs.org"]
  name      = "${var.hostname}-internal"
  type      = "A"
  value     = openstack_compute_instance_v2.vm.network.0.fixed_ip_v4
  ttl       = var.default_dns_ttl
}


resource "dme_dns_record" "cnames" {
  for_each  = toset(var.dns_cnames)
  domain_id = var.domain_dns["openmrs.org"]
  name      = each.value
  type      = "CNAME"
  value     = var.hostname
  ttl       = var.default_dns_ttl
}
