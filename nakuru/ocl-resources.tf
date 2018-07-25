# stg

resource "aws_s3_bucket" "ocl-bucket" {
  bucket = "openmrs-ocl-stg"
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

resource "aws_iam_user" "ocl-user" {
  name  = "ocl-stg-${var.hostname}"
}

resource "aws_iam_access_key" "ocl-user-key" {
  user = "${aws_iam_user.ocl-user.name}"
}

resource "aws_iam_user_policy" "ocl-user-policy" {
  name  = "ocl_stg"
  user  = "${aws_iam_user.ocl-user.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.ocl-bucket.arn}"]
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
      "Resource": "${aws_s3_bucket.ocl-bucket.arn}/*"
    }
  ]
}
EOF
}


# ad-hoc environment, for connect-a-thons and training workshops
resource "aws_s3_bucket" "ocl-bucket-adhoc" {
  bucket = "openmrs-ocl-adhoc"
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

resource "aws_iam_user" "ocl-user-adhoc" {
  name  = "ocl-adhoc-${var.hostname}"
}

resource "aws_iam_access_key" "ocl-user-key-adhoc" {
  user = "${aws_iam_user.ocl-user-adhoc.name}"
}

resource "aws_iam_user_policy" "ocl-user-policy-adhoc" {
  name  = "ocl_adhoc"
  user  = "${aws_iam_user.ocl-user-adhoc.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.ocl-bucket-adhoc.arn}"]
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
      "Resource": "${aws_s3_bucket.ocl-bucket-adhoc.arn}/*"
    }
  ]
}
EOF
}
