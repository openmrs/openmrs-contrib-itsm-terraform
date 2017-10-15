# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "docs.tfstate"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "openmrs-docs-logs"
  acl    = "log-delivery-write"
  tags {
    Terraform        = "docs"
  }
}

resource "aws_s3_bucket" "docs-s3" {
  bucket = "${var.bucket_name}"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadForGetBucketObjects",
      "Effect":"Allow",
      "Principal": "*",
      "Action":"s3:GetObject",
      "Resource":["arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
POLICY
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "log/"
  }
  versioning {
    enabled = true
  }
  tags {
    Terraform        = "docs"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_user" "bamboo-user" {
  name  = "bamboo-docs-upload"
}

resource "aws_iam_access_key" "bamboo-user-key" {
  user = "${aws_iam_user.bamboo-user.name}"
}

resource "aws_iam_user_policy" "bamboo-user-policy" {
  name  = "upload_docs"
  user  = "${aws_iam_user.bamboo-user.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.docs-s3.arn}"]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.docs-s3.arn}/*"
    }
  ]
}
EOF
}


resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = "${var.bucket_name}.s3.amazonaws.com"
    origin_id = "S3-${var.bucket_name}"
  }
  enabled = true
  default_cache_behavior {
    allowed_methods = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = "S3-${var.bucket_name}"
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 300
    max_ttl = 3600
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
