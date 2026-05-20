# ----------------------------------------------------------------------------------------------------------------------
# openmrs.net zone — redirect-only zone (same pattern as openmrs.com)
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "openmrs_net_apex" {
  zone_id = var.cloudflare_zone_id["openmrs.net"]
  name    = "openmrs.net"
  type    = "CNAME"
  content = "jinka.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "openmrs_net_wildcard" {
  zone_id = var.cloudflare_zone_id["openmrs.net"]
  name    = "*.openmrs.net"
  type    = "CNAME"
  content = "jinka.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "openmrs_net_atlassian_domain_verification" {
  zone_id = var.cloudflare_zone_id["openmrs.net"]
  name    = "openmrs.net"
  type    = "TXT"
  content = "\"atlassian-domain-verification=ZBVPzmrjeiIyvqNV2fMKwVQWWkfvy6pNyP6vep6nSIxG/ykqs0gKhwkrXJaopO8Q\""
  ttl     = var.default_dns_ttl
}

resource "cloudflare_dns_record" "openmrs_net_github_pages_challenge" {
  zone_id = var.cloudflare_zone_id["openmrs.net"]
  name    = "_github-pages-challenge-openmrs.openmrs.net"
  type    = "TXT"
  content = "\"94bcae76a01d5b8d6ba23175b24c42\""
  ttl     = var.default_dns_ttl
}
