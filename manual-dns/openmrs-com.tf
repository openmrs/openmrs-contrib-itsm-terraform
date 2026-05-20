# ----------------------------------------------------------------------------------------------------------------------
# openmrs.com zone — redirect-only zone
#
# Apex + wildcard point at jinka.openmrs.org via CNAME (Cloudflare flattens
# CNAMEs at the apex automatically). nginx on jinka serves the 301 to
# openmrs.org. See migration/http-redirects.md for the full redirect map.
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "openmrs_com_apex" {
  zone_id = var.cloudflare_zone_id["openmrs.com"]
  name    = "openmrs.com"
  type    = "CNAME"
  content = "jinka.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "openmrs_com_wildcard" {
  zone_id = var.cloudflare_zone_id["openmrs.com"]
  name    = "*.openmrs.com"
  type    = "CNAME"
  content = "jinka.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "openmrs_com_github_pages_challenge" {
  zone_id = var.cloudflare_zone_id["openmrs.com"]
  name    = "_github-pages-challenge-openmrs.openmrs.com"
  type    = "TXT"
  content = "\"86b07c4bd617cedefcdb70cbd17d45\""
  ttl     = var.default_dns_ttl
}
