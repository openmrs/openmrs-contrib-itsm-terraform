# discourse uploads its backup straight to S3
resource "aws_s3_bucket" "site-backups" {
  bucket = "openmrs-site-backup"
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user" "site-backup-user" {
  name = "backup-site"
}

resource "aws_iam_access_key" "site-backup-user-key" {
  user = "${aws_iam_user.site-backup-user.name}"
}

resource "aws_iam_user_policy" "site-backup-user-policy" {
  name = "backup_site-policy"
  user = "${aws_iam_user.site-backup-user.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": ["${aws_s3_bucket.site-backups.arn}"]
    },
    {
      "Action": [
         "s3:AbortMultipartUpload",
         "s3:GetObject",
         "s3:GetObjectAcl",
         "s3:GetObjectVersion",
         "s3:GetObjectVersionAcl",
         "s3:PutObject",
         "s3:PutObjectAcl",
         "s3:PutObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.site-backups.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    }
  ]
}
EOF
}
