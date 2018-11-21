# discourse uploads its backup straight to S3
resource "aws_s3_bucket" "talk-backups" {
  bucket = "openmrs-talk-backup"
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
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags {
    Terraform        = "${var.hostname}"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user" "talk-backup-user" {
  name = "backup-talk"
}

resource "aws_iam_access_key" "talk-backup-user-key" {
  user = "${aws_iam_user.talk-backup-user.name}"
}

resource "aws_iam_user_policy" "talk-backup-user-policy" {
  name = "backup_talk-policy"
  user = "${aws_iam_user.talk-backup-user.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.talk-backups.arn}"]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.talk-backups.arn}/*"
    }
  ]
}
EOF
}
