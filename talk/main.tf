# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "talk.tfstate"
  }
}

# any resources from the base stack
data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}

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
  tags {
    Terraform        = "${var.hostname}"
  }
}

resource "aws_iam_user" "backup-user" {
  name = "backup-${var.hostname}"
}

resource "aws_iam_access_key" "backup-user-key" {
  user = "${aws_iam_user.backup-user.name}"
}

resource "aws_iam_user_policy" "backup-user-policy" {
  name = "backup_${var.hostname}"
  user = "${aws_iam_user.backup-user.name}"
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
