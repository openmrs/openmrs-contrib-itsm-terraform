resource "aws_s3_bucket" "automatic-backups" {
  bucket = "openmrs-backups"
  lifecycle_rule {
    id      = "archive-and-delete"
    prefix  = ""
    enabled = true
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 180
    }
  }
  versioning {
    enabled = true
  }
  tags {
    Terraform        = "base-network"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "manual-backups" {
  bucket = "openmrs-manual-backup"
  versioning {
    enabled = true
  }
  tags {
    Terraform        = "base-network"
  }
  lifecycle {
    prevent_destroy = true
  }
}
