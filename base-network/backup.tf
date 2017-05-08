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
}

resource "aws_s3_bucket" "manual-backups" {
  bucket = "openmrs-backups-manual"
  lifecycle_rule {
    id      = "archive-and-delete"
    prefix  = ""
    enabled = true
    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
  versioning {
    enabled = true
  }
}
