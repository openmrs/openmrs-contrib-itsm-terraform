# ----------------------------------------------------------------------------------------------------------------------
# Very frequently they deprecate older images, and we need to change this
# terraform is configured to not recreate images if this variable changes
# ----------------------------------------------------------------------------------------------------------------------

variable "image_ubuntu_22" {
  default = "657aed7d-e862-46da-b3d5-d9a0e301dcf4"
}

variable "image_ubuntu_24" {
  default = "9fd63017-112e-4b6c-8b9e-238892895199"
}

variable "ssh_key_file_v2" {
  description = "SSH key used to provision VMs"
  sensitive   = true
  default     = "../conf/provisioning/ssh/terraform-api.key"
}

variable "ansible_repo" {
  default = "git@github.com:openmrs/openmrs-contrib-itsmresources.git"
}

variable "ssh_username_ubuntu_20" {
  default = "ubuntu"
}

variable "project_name" {
  description = "Project name in Jetstream"
  default     = "TG-ASC170002"
}

variable "domain_dns" {
  description = "DNS domains ID"
  default = {
    "openmrs.org" = "4712658"
    "openmrs.net" = "4714812"
    "openmrs.com" = "4714813"
    "om.rs"       = "4714810"
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone IDs per domain"
  default = {
    "openmrs.org" = "b4971e2d7be2ee072cab9e438f687838"
    "openmrs.net" = "0f28c530f91a49051b191fb4c395c710"
    "openmrs.com" = "9a92b877cadbfe3b5e4608121faa8a39"
    "om.rs"       = "e998bf6d653ca86601bb161c6c65cc38"
  }
}

variable "main_domain_dns" {
  default = "openmrs.org"
}

variable "default_dns_ttl" {
  description = "Default TTL (seconds) for DNS records managed by this repo"
  default     = 3600
}

variable "mail_dns_ttl" {
  description = "TTL (seconds) for mail-config records (MX, DKIM, sender verification)"
  default     = 86400
}

variable "dme_apikey" {
  sensitive = true
  default   = ""
}

variable "dme_secretkey" {
  sensitive = true
  default   = ""
}

variable "cf_api_token" {
  description = "Cloudflare API token"
  sensitive   = true
  default     = ""
}

variable "cf_account_id" {
  default = "8b602baa4865372bf49619922b9913d6"
}
