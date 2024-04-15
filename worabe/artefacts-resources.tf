resource "aws_s3_bucket" "bamboo-artefacts-bucket" {
  bucket = "openmrs-bamboo-artefacts"

  tags = {
    Terraform = var.hostname
  }
  lifecycle {
    prevent_destroy = true
  }
}

# ---------------------------------------------------------------------
# Leaving this user with the old username/machine, for compatibility
# ---------------------------------------------------------------------

resource "aws_iam_user" "bamboo-artefacts-user" {
  name = "bamboo-artefacts-lobi"
}

resource "aws_iam_access_key" "bamboo-artefacts-user-key" {
  user = aws_iam_user.bamboo-artefacts-user.name
}

resource "aws_iam_user_policy" "bamboo-artefacts-user-policy" {
  name   = "bamboo-artefacts"
  user   = aws_iam_user.bamboo-artefacts-user.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.bamboo-artefacts-bucket.arn}"]
    },
    {
      "Action": [
        "s3:PutObject*",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload",
        "s3:DeleteObject*",
        "s3:GetObject*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bamboo-artefacts-bucket.arn}/*"
    }
  ]
}
EOF

}

