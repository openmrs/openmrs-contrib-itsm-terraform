# ----------------------------------------------------------------------------------------------------------------------
# openmrs.org zone — manual records (not managed by per-VM stacks, adaba/gode/jinka/cdn-resources/docs/kubernetes,
# or jinka's expanded dns_cnames list).
#
# Vestigial records intentionally NOT carried over from DME:
#   - chat.openmrs.org TXT (SPF) and the two SRV records under _xmpp-{client,server}._tcp.chat.openmrs.org;
#     chat.openmrs.org is now a CNAME → jinka redirect, no chat service runs at that name anymore.
#   - The deprecated apex SPF-typed record (RFC 7208 deprecates SPF in favour of TXT; the TXT version is kept).
#   - nightly.openmrs.org (retired — destination int-refapp.openmrs.org no longer exists).
# ----------------------------------------------------------------------------------------------------------------------

locals {
  # Shared Google Workspace MX target list, used by both the apex and ga.openmrs.org.
  google_workspace_mx = [
    { priority = 10, target = "aspmx.l.google.com" },
    { priority = 20, target = "alt1.aspmx.l.google.com" },
    { priority = 20, target = "alt2.aspmx.l.google.com" },
    { priority = 30, target = "aspmx2.googlemail.com" },
    { priority = 30, target = "aspmx3.googlemail.com" },
    { priority = 30, target = "aspmx4.googlemail.com" },
    { priority = 30, target = "aspmx5.googlemail.com" },
  ]

  apex_verification_txts = [
    "OSSRH-67009",
    "00df000000061l8maa",
    "have-i-been-pwned-verification=be1078f6fa217ec4987eaa9159f37a90",
    "google-site-verification=lUCkW8r8SYIlfBa6AXSuvrz1Iyw5khBXZmctXricL2U",
    "globalsign-domain-verification=MT3LmRzGYPgORWLlSBkPpAUpBDH9kl8xxYmB6FjtjY",
    "atlassian-domain-verification=VuGBujoVFWafPPRX7IedCYNeI6gUiJhWLsa2N29Ra7itcHm5JyiTfezcvpfbglPH",
    "atlassian-domain-verification=prCuZpfajIHzMgahOfwlE8Ge9z8vdnpDnR4i4UeBE4tcjXOEixaxiAilfM8SZb2v",
  ]

  github_pages_subdomains = [
    "devmanual",
    "fhir",
    "guide",
    "json",
    "o3-docs",
    "o3-performance",
    "radar",
    "rest",
    "security-dashboard",
    "slack",
  ]

  google_xmpp_srv = {
    "jabber-default"      = { name = "_jabber._tcp", priority = 5, port = 5269, target = "xmpp-server.l.google.com" }
    "jabber-1"            = { name = "_jabber._tcp", priority = 20, port = 5269, target = "xmpp-server1.l.google.com" }
    "jabber-2"            = { name = "_jabber._tcp", priority = 20, port = 5269, target = "xmpp-server2.l.google.com" }
    "jabber-3"            = { name = "_jabber._tcp", priority = 20, port = 5269, target = "xmpp-server3.l.google.com" }
    "jabber-4"            = { name = "_jabber._tcp", priority = 20, port = 5269, target = "xmpp-server4.l.google.com" }
    "xmpp-client-default" = { name = "_xmpp-client._tcp", priority = 5, port = 5222, target = "talk.l.google.com" }
    "xmpp-client-1"       = { name = "_xmpp-client._tcp", priority = 20, port = 5222, target = "talk1.l.google.com" }
    "xmpp-client-2"       = { name = "_xmpp-client._tcp", priority = 20, port = 5222, target = "talk2.l.google.com" }
    "xmpp-client-3"       = { name = "_xmpp-client._tcp", priority = 20, port = 5222, target = "talk3.l.google.com" }
    "xmpp-client-4"       = { name = "_xmpp-client._tcp", priority = 20, port = 5222, target = "talk4.l.google.com" }
    "xmpp-server-default" = { name = "_xmpp-server._tcp", priority = 5, port = 5269, target = "xmpp-server.l.google.com" }
    "xmpp-server-1"       = { name = "_xmpp-server._tcp", priority = 20, port = 5269, target = "xmpp-server1.l.google.com" }
    "xmpp-server-2"       = { name = "_xmpp-server._tcp", priority = 20, port = 5269, target = "xmpp-server2.l.google.com" }
    "xmpp-server-3"       = { name = "_xmpp-server._tcp", priority = 20, port = 5269, target = "xmpp-server3.l.google.com" }
    "xmpp-server-4"       = { name = "_xmpp-server._tcp", priority = 20, port = 5269, target = "xmpp-server4.l.google.com" }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Apex (openmrs.org) — A records, MX, SPF, domain-verification TXTs
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "openmrs_org_apex_a" {
  for_each = toset(["192.0.78.137", "192.0.78.235"])

  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "openmrs.org"
  type    = "A"
  content = each.value
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "openmrs_org_apex_mx" {
  for_each = { for mx in local.google_workspace_mx : mx.target => mx }

  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "openmrs.org"
  type     = "MX"
  priority = each.value.priority
  content  = each.value.target
  ttl      = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "openmrs_org_apex_spf" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "openmrs.org"
  type    = "TXT"
  content = "\"v=spf1 a mx include:_spf.google.com include:servers.mcsv.net include:mandrillapp.com include:_spf.atlassian.net ~all\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "openmrs_org_apex_verification_txt" {
  for_each = toset(local.apex_verification_txts)

  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "openmrs.org"
  type    = "TXT"
  content = "\"${each.value}\""
  ttl     = var.default_dns_ttl
}

# ----------------------------------------------------------------------------------------------------------------------
# DMARC
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "dmarc" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_dmarc.openmrs.org"
  type    = "TXT"
  content = "\"v=DMARC1; p=quarantine; rua=mailto:dmarc@openmrs.org\""
  ttl     = var.mail_dns_ttl
}

# ----------------------------------------------------------------------------------------------------------------------
# DKIM — _domainkey records at the zone root
#   k2/k3   → Mailchimp (mcsv.net)
#   mte1/2  → Mandrill
#   s1/s2   → Atlassian
#   _adsp   → DKIM policy (legacy RFC 5617, "dkim=unknown")
# Plus the in-zone DKIM TXTs (mandrill, mesmtp, omrsdkim, 20140131030047.pm).
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "adsp_domainkey" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_adsp._domainkey.openmrs.org"
  type    = "TXT"
  content = "\"dkim=unknown\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "mailchimp_k2_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "k2._domainkey.openmrs.org"
  type    = "CNAME"
  content = "dkim2.mcsv.net"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "mailchimp_k3_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "k3._domainkey.openmrs.org"
  type    = "CNAME"
  content = "dkim3.mcsv.net"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "mandrill_mte1_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mte1._domainkey.openmrs.org"
  type    = "CNAME"
  content = "dkim1.mandrillapp.com"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "mandrill_mte2_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mte2._domainkey.openmrs.org"
  type    = "CNAME"
  content = "dkim2.mandrillapp.com"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "atlassian_s1_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "s1._domainkey.openmrs.org"
  type    = "CNAME"
  content = "s1._domainkey.atlassian.net"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "atlassian_s2_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "s2._domainkey.openmrs.org"
  type    = "CNAME"
  content = "s2._domainkey.atlassian.net"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "mandrill_dkim_txt" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mandrill._domainkey.openmrs.org"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrLHiExVd55zd/IQ/J/mRwSRMAocV/hMB3jXwaHH36d9NaVynQFYV8NaWi69c1veUtRzGt7yAioXqLj7Z4TeEUoOLgrKsn8YnckGs9i3B3tVFB+Ch/4mPhXWiNfNdynHWBcPcbJ8kjEQ2U8y78dHZj1YeRXXVvWob2OaKynO8/lQIDAQAB;\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "mesmtp_dkim_txt" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mesmtp._domainkey.openmrs.org"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDmFpTRtxCA629TwGy3NbouOY7sRVm0MXg3TfSWMXoOe5Rxj8hBdI+PmA9cB8rRfHA+/a0LvP1EFZHEvcjIEZJ78wbS4FcIf3L5rofUcJPkuSi0tA5NyJCNoT41bM/P1f/dAlXo3AOQGxD6OOIg7mcyNqQMeYlcV+ou6H3OEHk4YQIDAQAB\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "omrsdkim_dkim_txt" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "omrsdkim._domainkey.openmrs.org"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; t=y; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCCygSQsNCO2vbBhyaz09HIQCS/gt/Znkw6OU1DfjP96oKKboSs7FvX3jFX8bLyuL7idLSY5XOPAS/brPKZoNO/+CkKnhwQCOq7rOF2eldpbQrYBX6mMY/LWlxhCcw1z3qcJ0v3SyHSv/V9cJFBAYfiDnmB4H/mdumIIUtRRehWNQIDAQAB\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "pm_dkim_txt" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "20140131030047.pm._domainkey.openmrs.org"
  type    = "TXT"
  content = "\"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCRdoFZEWV0aOVdCCO7cIPAY0YSXEmaB5IqCEqSBNQl3wCt24578XxNnz13QUEBxRtAox1h8+VzT6RCsRn+c/7VVTlYN9jEYWcvR92BZGLytYOqR4fOq4T09eJ1Ndpt33oNXsKQiyGVM2uWLr7rdBlLOWjVKEvU9/BYesrwaRp0uQIDAQAB\""
  ttl     = var.mail_dns_ttl
}

# ----------------------------------------------------------------------------------------------------------------------
# DKIM at deeper subdomains: smtp.*, smtp-stg.*, id-new.*
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "smtp_mte_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mte._domainkey.smtp.openmrs.org"
  type    = "CNAME"
  content = "dkim1.mandrillapp.com"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "smtp_mte2_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mte2._domainkey.smtp.openmrs.org"
  type    = "CNAME"
  content = "dkim2.mandrillapp.com"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "smtp_stg_mte1_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mte1._domainkey.smtp-stg.openmrs.org"
  type    = "CNAME"
  content = "dkim1.mandrillapp.com"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "smtp_stg_mte2_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mte2._domainkey.smtp-stg.openmrs.org"
  type    = "CNAME"
  content = "dkim2.mandrillapp.com"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "id_new_k2_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "k2._domainkey.id-new.openmrs.org"
  type    = "CNAME"
  content = "dkim2.mcsv.net"
  ttl     = var.mail_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "id_new_k3_dkim" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "k3._domainkey.id-new.openmrs.org"
  type    = "CNAME"
  content = "dkim3.mcsv.net"
  ttl     = var.mail_dns_ttl
  proxied = false
}

# ----------------------------------------------------------------------------------------------------------------------
# Mandrill verification TXTs at smtp / smtp-stg
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "smtp_mandrill_verify" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "smtp.openmrs.org"
  type    = "TXT"
  content = "\"mandrill_verify.xNXyHziMFDVY-kuiBl2GMw\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "smtp_stg_mandrill_verify" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "smtp-stg.openmrs.org"
  type    = "TXT"
  content = "\"mandrill_verify.iynD2ZwHpLB7atww51svFg\""
  ttl     = var.mail_dns_ttl
}

# ----------------------------------------------------------------------------------------------------------------------
# GitHub domain / Pages verification TXTs
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "github_challenge_openmrs_org" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_github-challenge-openmrs-org.openmrs.org"
  type    = "TXT"
  content = "\"e45d438ffc\""
  ttl     = var.default_dns_ttl
}

resource "cloudflare_dns_record" "github_pages_challenge" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_github-pages-challenge-openmrs.openmrs.org"
  type    = "TXT"
  content = "\"0d9c2ba57a92b113d31e9c6a4019d4\""
  ttl     = var.default_dns_ttl
}

# ----------------------------------------------------------------------------------------------------------------------
# SRV — Google XMPP/Jabber at apex + the legacy _client._smtp at apex
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "google_xmpp_srv" {
  for_each = local.google_xmpp_srv

  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "${each.value.name}.openmrs.org"
  type     = "SRV"
  priority = each.value.priority
  ttl      = var.default_dns_ttl
  data = {
    priority = each.value.priority
    weight   = 0
    port     = each.value.port
    target   = each.value.target
  }
}

# Legacy SMTP service-discovery announcement; targets the apex on port 1 (no-op port).
resource "cloudflare_dns_record" "client_smtp_srv" {
  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "_client._smtp.openmrs.org"
  type     = "SRV"
  priority = 1
  ttl      = var.mail_dns_ttl
  data = {
    priority = 1
    weight   = 1
    port     = 1
    target   = "openmrs.org"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# ga.openmrs.org — separate Google Workspace mail domain for the "ga" subdomain
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "ga_openmrs_org_mx" {
  for_each = { for mx in local.google_workspace_mx : mx.target => mx }

  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "ga.openmrs.org"
  type     = "MX"
  priority = each.value.priority
  content  = each.value.target
  ttl      = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "ga_adsp_domainkey" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_adsp._domainkey.ga.openmrs.org"
  type    = "TXT"
  content = "\"dkim=unknown\""
  ttl     = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "ga_mesmtp_dkim_txt" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "mesmtp._domainkey.ga.openmrs.org"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDLk/CUCXwqS/M9O8agjwclwQxexvdRbjgHaUBMKZvg5N7Lg+feYn+9jM7w60Jk6WU53m0BHCjrbgMI2RlfIpgF+jKN7ziBmvULXWCraZPk6xHbt9HiUHqWV60yJfU1wry442WRgw1/1wKCAp1q4pnTmrmt22gWm4yhFafvOIFhTQIDAQAB\""
  ttl     = var.mail_dns_ttl
}

# Google Search Console verification for ga.openmrs.org
resource "cloudflare_dns_record" "ga_google_site_verification" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "google81d437c65dbb83d3.ga.openmrs.org"
  type    = "CNAME"
  content = "google.com"
  ttl     = var.default_dns_ttl
  proxied = false
}

# ----------------------------------------------------------------------------------------------------------------------
# mail.openmrs.org — Mandrill inbound relay
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "mail_mandrill_mx_1" {
  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "mail.openmrs.org"
  type     = "MX"
  priority = 10
  content  = "30039905.in1.mandrillapp.com"
  ttl      = var.mail_dns_ttl
}

resource "cloudflare_dns_record" "mail_mandrill_mx_2" {
  zone_id  = var.cloudflare_zone_id["openmrs.org"]
  name     = "mail.openmrs.org"
  type     = "MX"
  priority = 20
  content  = "30039905.in2.mandrillapp.com"
  ttl      = var.mail_dns_ttl
}

# ----------------------------------------------------------------------------------------------------------------------
# ACM validation CNAMEs — DNS-01 challenge records for AWS Certificate Manager
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "acm_validation_assets" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_ad71ce47adeaba48bb906889b3fb81bc.assets.openmrs.org"
  type    = "CNAME"
  content = "_d68df01c20c7477d8120f0511de27d8d.djqtsrsxkq.acm-validations.aws"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "acm_validation_cdn" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_dd69ba024ca345a3a90dd2085bcf415b.cdn.openmrs.org"
  type    = "CNAME"
  content = "_0acb2c99299205cfc3d9364cae01e66e.djqtsrsxkq.acm-validations.aws"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "acm_validation_dev3" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_bc26c6d41bfd2996e41feccd8ef47eb1.dev3.openmrs.org"
  type    = "CNAME"
  content = "_1ab27a4514d4baa8bdd1702677ea35ea.xlfgrmvvlj.acm-validations.aws"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "acm_validation_status" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "_8bb7f67dd51c93ba25999b0a44fb12f3.status.openmrs.org"
  type    = "CNAME"
  content = "_19f1762f96fbd63fb81df3bae19aa19f.hkvuiqjoua.acm-validations.aws"
  ttl     = var.default_dns_ttl
  proxied = false
}

# ----------------------------------------------------------------------------------------------------------------------
# GitHub Pages CNAMEs — all → openmrs.github.io
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "github_pages_cname" {
  for_each = toset(local.github_pages_subdomains)

  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "${each.value}.openmrs.org"
  type    = "CNAME"
  content = "openmrs.github.io"
  ttl     = var.default_dns_ttl
  proxied = false
}

# ----------------------------------------------------------------------------------------------------------------------
# Other CNAMEs — third-party services, one-off mappings
# ----------------------------------------------------------------------------------------------------------------------

resource "cloudflare_dns_record" "answers_cname" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "answers.openmrs.org"
  type    = "CNAME"
  content = "talk.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

# Mandrill click-tracking CNAME for "cl." links in outbound mail
resource "cloudflare_dns_record" "cl_mandrill" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "cl.openmrs.org"
  type    = "CNAME"
  content = "mandrillapp.com"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "ci_old" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "ci-old.openmrs.org"
  type    = "CNAME"
  content = "worabe.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "db" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "db.openmrs.org"
  type    = "CNAME"
  content = "sawla.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "db_internal" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "db-internal.openmrs.org"
  type    = "CNAME"
  content = "sawla-internal.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "listarchives" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "listarchives.openmrs.org"
  type    = "CNAME"
  content = "openmrs-mailing-list-archives.1560443.n2.nabble.com"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "notes" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "notes.openmrs.org"
  type    = "CNAME"
  content = "etherpad.osuosl.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "o3_dev_docs_vercel" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "o3-dev.docs.openmrs.org"
  type    = "CNAME"
  content = "cname.vercel-dns.com"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "planet" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "planet.openmrs.org"
  type    = "CNAME"
  content = "web2.osuosl.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "rss" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "rss.openmrs.org"
  type    = "CNAME"
  content = "planet.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "status" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "status.openmrs.org"
  type    = "CNAME"
  content = "domain.statusio.com"
  ttl     = var.default_dns_ttl
  proxied = false
}

resource "cloudflare_dns_record" "svn" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "svn.openmrs.org"
  type    = "CNAME"
  content = "openmrs1.osuosl.org"
  ttl     = var.default_dns_ttl
  proxied = false
}

# ----------------------------------------------------------------------------------------------------------------------
# A records — non-VM hosts that aren't managed by a per-VM stack
# ----------------------------------------------------------------------------------------------------------------------

# sawla — the database host. Not currently in a TF single-machine stack.
resource "cloudflare_dns_record" "sawla_a" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "sawla.openmrs.org"
  type    = "A"
  content = "149.165.155.70"
  ttl     = var.default_dns_ttl
  proxied = false
}

# Private-network address for sawla. Publishes an RFC 1918 IP to public DNS; flagged
# for cleanup under task #9 alongside the *-internal records emitted by single-machine.
resource "cloudflare_dns_record" "sawla_internal_a" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "sawla-internal.openmrs.org"
  type    = "A"
  content = "10.0.2.34"
  ttl     = var.default_dns_ttl
  proxied = false
}

# ----------------------------------------------------------------------------------------------------------------------
# acme-dns (chiro) — DNS-01 challenge server owning the acme.openmrs.org subdomain, which
# we use for DNS-01 ACME challenges
#
#   auth.acme.openmrs.org  A     -> chiro's public IP (the delegated zone's nameserver glue)
#   acme.openmrs.org       NS    -> auth.acme.openmrs.org (delegates the challenge subzone)
#   acme-internal          CNAME -> chiro-internal.openmrs.org (stable private API endpoint;
#                                   mirrors db-internal -> sawla-internal, so the acme-dns
#                                   host can be moved with a one-line repoint)
# ----------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "chiro" {
  backend = "s3"
  config = {
    bucket = "openmrs-terraform-state-files"
    key    = "chiro.tfstate"
    region = "us-west-2"
  }
}

resource "cloudflare_dns_record" "acme_dns_auth_a" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "auth.acme.openmrs.org"
  type    = "A"
  content = data.terraform_remote_state.chiro.outputs.ip_address
  ttl     = var.default_dns_ttl
  proxied = false # a nameserver, never proxied
}

resource "cloudflare_dns_record" "acme_dns_delegation_ns" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "acme.openmrs.org"
  type    = "NS"
  content = "auth.acme.openmrs.org"
  ttl     = var.default_dns_ttl
}

resource "cloudflare_dns_record" "acme_internal" {
  zone_id = var.cloudflare_zone_id["openmrs.org"]
  name    = "acme-internal.openmrs.org"
  type    = "CNAME"
  content = "chiro-internal.openmrs.org"
  ttl     = var.default_dns_ttl
  proxied = false
}
