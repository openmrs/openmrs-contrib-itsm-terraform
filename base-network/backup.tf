resource "aws_s3_bucket" "automatic-backups" {
  bucket = "openmrs-backups"

  # The arguments that were here are deprecated, and will be removed in a future major version: Will come back to this in the near future and remove the blocks in another ticket
  # Ref - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#lifecycle-rule

  tags = {
    Terraform = "base-network"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "openmrs-backups-logs"

  tags = {
    Terraform = "base-network"
  }
}

resource "aws_s3_bucket" "manual-backups" {
  bucket = "openmrs-manual-backup"

  tags = {
    Terraform = "base-network"
  }
  lifecycle {
    prevent_destroy = true
  }
}

