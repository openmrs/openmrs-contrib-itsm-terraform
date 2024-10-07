resource "dme_dns_record" "hostname" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = var.hostname
  type      = "A"
  value     = openstack_networking_floatingip_v2.ip.address
  ttl       = 300
}

resource "dme_dns_record" "private_hostname" {
  count     = var.has_private_dns ? 1 : 0
  domain_id = var.domain_dns["openmrs.org"]
  name      = "${var.hostname}-internal"
  type      = "A"
  value     = openstack_compute_instance_v2.vm.network.0.fixed_ip_v4
  ttl       = 300
}


resource "dme_dns_record" "cnames" {
  count     = length(var.dns_cnames)
  domain_id = var.domain_dns["openmrs.org"]
  name      = element(var.dns_cnames, count.index)
  type      = "CNAME"
  value     = var.hostname
  ttl       = 300
}
