resource "aws_s3_bucket" "automatic-backups" {
  bucket = "openmrs-backups"

  tags = {
    Terraform = "base-network"
  }
  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_bucket" {
  bucket = aws_s3_bucket.automatic-backups.id

  rule {
    id      = "archive-and-delete"
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 180
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "versioning_bucket" {
  bucket = aws_s3_bucket.automatic-backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_bucket" {
  bucket = aws_s3_bucket.automatic-backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "openmrs-backups-logs"
  tags = {
    Terraform = "base-network"
  }
}

resource "aws_s3_bucket_acl" "acl_log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "logging_bucket" {
  bucket = aws_s3_bucket.automatic-backups.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
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

resource "aws_s3_bucket_versioning" "versioning_manual_bucket" {
  bucket = aws_s3_bucket.manual-backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_manual_bucket" {
  bucket = aws_s3_bucket.manual-backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

