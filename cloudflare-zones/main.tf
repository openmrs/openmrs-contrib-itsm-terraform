# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "cloudflare-zones.tfstate"
    region = "us-west-2"
  }
}

resource "cloudflare_zone" "openmrs" {
  for_each = toset(keys(var.domain_dns))

  account = {
    id = var.cf_account_id
  }
  name = each.key
  type = "full"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_zone_setting" "openmrs_org_ssl" {
  zone_id    = cloudflare_zone.openmrs["openmrs.org"].id
  setting_id = "ssl"
  value      = "strict"
}

# Timed-HMAC bypass letting an API client that signs its requests through Super Bot Fight Mode without
# whitelisting its egress IPs.
#
# X-OMRS-Token is in the format <ts>-<base64 hash> where the hash is SHA256(key, uri_path + ts).
#
# The "|" separator is just here to distinguish the URL from the token. It is stripped out by setting
# the <length of separator> argument to `is_timed_hmac_valid_v0()`
locals {
  talk_hmac_message = "concat(http.request.uri, \"|\", http.request.headers[\"x-omrs-token\"][0])"

  talk_hmac_conditions = [
    "http.host eq \"talk.openmrs.org\"",
    "any(http.request.headers[\"x-omrs-token\"][*] ne \"\")",
    "is_timed_hmac_valid_v0(\"${var.talk_bahmni_hmac_key}\", ${local.talk_hmac_message}, 3600, http.request.timestamp.sec, 1, \"s\")",
  ]

  # An empty key would deploy a rule that anyone can sign against, so drop the rule until one is set.
  talk_hmac_rules = var.talk_bahmni_hmac_key == "" ? [] : [
    {
      ref         = "sbfm_skip_talk_hmac"
      description = "Bypass Super Bot Fight Mode for talk.openmrs.org clients presenting a valid HMAC token"
      expression  = "(${join(" and ", local.talk_hmac_conditions)})"
      action      = "skip"
      action_parameters = {
        phases = ["http_request_sbfm"]
        products = ["bic"]
      }
      logging = {
        enabled = true
      }
    }
  ]
}

# Custom WAF rules for openmrs.org
resource "cloudflare_ruleset" "openmrs_org_custom_firewall" {
  zone_id = cloudflare_zone.openmrs["openmrs.org"].id
  name    = "openmrs.org custom firewall rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = concat([
    {
      ref         = "sbfm_skip_omrs"
      description = "Bypass Super Bot Fight Mode for internal bots"
      expression  = "(ip.src eq 149.165.154.224)"
      action      = "skip"
      action_parameters = {
        phases = ["http_request_sbfm"]
      }
      logging = {
        enabled = true
      }
    }
  ], local.talk_hmac_rules)
}
