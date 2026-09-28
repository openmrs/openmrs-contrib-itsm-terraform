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

# Read-only Discourse JSON endpoints the Bahmni integration polls. Its client is not a browser, so
# both Super Bot Fight Mode and Browser Integrity Check reject it; skipping them here keeps the
# integration working without the client having to prove anything to Cloudflare. Discourse still
# applies its own permissions to every one of these paths.
#
# Pro has no regex operator and wildcard "*" spans "/", so a pattern cannot pin a path segment. These
# are correspondingly broader than the endpoints they cover: any .json under the prefix matches. The
# method check keeps the skip to reads, and matching on uri.path ignores query strings.
locals {
  talk_read_path_patterns = [
    "/categories.json",
    "/users/*.json", # /users/<username>.json, /users/<username>/emails.json
    "/c/*.json",     # /c/<name>/<id>.json, /c/<id>/show.json
    "/t/*.json",     # /t/<id>.json, /t/<id>/posts.json
  ]

  talk_read_conditions = [
    "http.host eq \"talk.openmrs.org\"",
    "http.request.method eq \"GET\"",
    "(${join(" or ", [for p in local.talk_read_path_patterns : "http.request.uri.path wildcard \"${p}\""])})",
  ]
}

# Custom WAF rules for openmrs.org
resource "cloudflare_ruleset" "openmrs_org_custom_firewall" {
  zone_id = cloudflare_zone.openmrs["openmrs.org"].id
  name    = "openmrs.org custom firewall rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = [
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
    },
    {
      ref         = "sbfm_skip_talk_reads"
      description = "Bypass Super Bot Fight Mode and Browser Integrity Check for talk.openmrs.org read endpoints"
      expression  = "(${join(" and ", local.talk_read_conditions)})"
      action      = "skip"
      action_parameters = {
        phases   = ["http_request_sbfm"]
        products = ["bic"]
      }
      logging = {
        enabled = true
      }
    }
  ]
}
