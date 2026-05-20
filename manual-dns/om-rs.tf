# ----------------------------------------------------------------------------------------------------------------------
# om.rs zone — manual records (not managed by per-VM stacks)
# Apex/wildcard A records are managed by the jinka stack via ANAME→CNAME flattening.
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "om_rs_spf" {
  zone_id = var.cloudflare_zone_id["om.rs"]
  name    = "om.rs"
  type    = "TXT"
  content = "\"v=spf1 a mx include:_spf.google.com include:spf.mandrillapp.com include:spf.mtasv.net ~all\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "om_rs_google_dkim" {
  zone_id = var.cloudflare_zone_id["om.rs"]
  name    = "google._domainkey.om.rs"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCPhoZTn1ahD5pRNzHaz9Q4VwKHghVRhDsGl7SmdgjB3vWrGq+SpedHJ7395ZFiJyTUlmZ5TV/d2eW6qpCf/iBhwtbP+FevwPyF32KGlhjvtfevn9On55KysOBzTyPO00ljL9B6RK/r3PERI5Gu50bcNeEMmiFEVXs0zLiENGToCQIDAQAB\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "om_rs_mandrill_dkim" {
  zone_id = var.cloudflare_zone_id["om.rs"]
  name    = "mandrill._domainkey.om.rs"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrLHiExVd55zd/IQ/J/mRwSRMAocV/hMB3jXwaHH36d9NaVynQFYV8NaWi69c1veUtRzGt7yAioXqLj7Z4TeEUoOLgrKsn8YnckGs9i3B3tVFB+Ch/4mPhXWiNfNdynHWBcPcbJ8kjEQ2U8y78dHZj1YeRXXVvWob2OaKynO8/lQIDAQAB;\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "om_rs_g_mandrill" {
  zone_id = var.cloudflare_zone_id["om.rs"]
  name    = "g.om.rs"
  type    = "CNAME"
  content = "mandrillapp.com"
  ttl     = var.default_dns_ttl
  proxied = false
}
