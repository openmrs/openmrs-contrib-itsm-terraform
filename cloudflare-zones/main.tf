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
    }
  ]
}
