# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "bamenda.tfstate"
  }
}

module "backup-user" {
  source            = "../modules/backup-user"

  # Change values in variables.tf file instead
  hostname          = "${var.hostname}"
}
