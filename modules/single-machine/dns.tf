resource "dme_dns_record" "hostname" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = var.hostname
  type      = "A"
  value     = openstack_networking_floatingip_v2.ip.address
  ttl       = var.default_dns_ttl
}

resource "cloudflare_dns_record" "hostname" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "${var.hostname}.openmrs.org"
  type    = "A"
  content = openstack_networking_floatingip_v2.ip.address
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "dme_dns_record" "private_hostname" {
  count     = var.has_private_dns ? 1 : 0
  domain_id = var.domain_dns["openmrs.org"]
  name      = "${var.hostname}-internal"
  type      = "A"
  value     = openstack_compute_instance_v2.vm.network.0.fixed_ip_v4
  ttl       = var.default_dns_ttl
}

resource "cloudflare_dns_record" "private_hostname" {
  count   = var.has_private_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "${var.hostname}-internal.openmrs.org"
  type    = "A"
  content = openstack_compute_instance_v2.vm.network.0.fixed_ip_v4
  ttl     = var.default_dns_ttl
  proxied = false
}


resource "dme_dns_record" "cnames" {
  for_each  = toset(var.dns_cnames)
  domain_id = var.domain_dns["openmrs.org"]
  name      = each.value
  type      = "CNAME"
  value     = var.hostname
  ttl       = var.default_dns_ttl
}

resource "cloudflare_dns_record" "cnames" {
  for_each = toset(concat(var.dns_cnames, var.cf_only_dns_cnames))
  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "${each.value}.openmrs.org"
  type     = "CNAME"
  content  = "${var.hostname}.openmrs.org"
  # Proxied (orange-cloud) records must use TTL "auto" (1); DNS-only ones keep the default.
  proxied = contains(var.cf_proxied_cnames, each.value)
  ttl     = contains(var.cf_proxied_cnames, each.value) ? 1 : var.default_dns_ttl
}

# _acme-challenge CNAMEs for DNS-01 via acme-dns. Each entry delegates a name's ACME challenge
# to its isolated acme-dns account; content is the account fulldomain (<uuid>.acme.openmrs.org)
# emitted by registration on the host. See acme-dns-dns01-terraform-brief.md.
resource "cloudflare_dns_record" "acme_challenge" {
  for_each = var.acme_challenge_cnames
  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "_acme-challenge.${each.key}.openmrs.org"
  type     = "CNAME"
  content  = each.value
  ttl      = var.default_dns_ttl
  proxied  = false
}
