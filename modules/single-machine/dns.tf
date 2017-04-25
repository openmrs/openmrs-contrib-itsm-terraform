provider "dme" {
  usesandbox = false
}

resource "dme_record" "www" {
  domainid    = "${var.domain_dns}"
  name        = "${var.hostname}"
  type        = "A"
  value       = "${openstack_compute_floatingip_v2.ip.address}"
  ttl         = 300
  gtdLocation = "DEFAULT"
}
