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
