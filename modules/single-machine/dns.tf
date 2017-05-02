resource "dme_record" "hostname" {
  domainid    = "${var.domain_dns["openmrs.org"]}"
  name        = "${var.hostname}"
  type        = "A"
  value       = "${openstack_compute_floatingip_v2.ip.address}"
  ttl         = 300
  gtdLocation = "DEFAULT"
}
