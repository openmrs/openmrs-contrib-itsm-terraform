# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "docs.tfstate"
  }
}



resource "aws_s3_bucket" "docs-s3" {
  bucket = var.bucket_name

  tags = {
    Terraform = "docs"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_acl" "docs-acl" {
  bucket = aws_s3_bucket.docs-s3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "docs-versioning" {
  bucket = aws_s3_bucket.docs-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "docs-website" {
  bucket = aws_s3_bucket.docs-s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "docs-policy" {
  bucket = aws_s3_bucket.docs-s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowGetObjects"
    Statement = [
      {
        Sid       = "AllowPublic"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.docs-s3.arn}/**"
      }
    ]
  })
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "openmrs-docs-logs"
  tags = {
    Terraform = "docs"
  }
}

resource "aws_s3_bucket_acl" "acl_log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "docs-logging" {
  bucket = aws_s3_bucket.docs-s3.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}




resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.docs-s3.website_endpoint
    origin_id   = "S3-${var.bucket_name}"
    custom_origin_config {
      origin_read_timeout    = 60
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  enabled             = true
  aliases             = ["docs.openmrs.org", "resources.openmrs.org"]
  default_root_object = "index.html"
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.log_bucket.bucket_domain_name
    prefix          = "cloudfront"
  }
  tags = {
    Terraform = "docs"
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 3600
  }
  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "dme_dns_record" "docs" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "docs"
  type      = "CNAME"
  value     = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}."
  ttl       = 300
}

resource "dme_dns_record" "resources" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "resources"
  type      = "CNAME"
  value     = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}."
  ttl       = 300
}

resource "aws_iam_user" "bamboo-user" {
  name = "bamboo-docs-upload"
}

resource "aws_iam_access_key" "bamboo-user-key" {
  user = aws_iam_user.bamboo-user.name
}

resource "aws_iam_user_policy" "bamboo-user-policy" {
  name   = "upload_docs"
  user   = aws_iam_user.bamboo-user.name
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

resource "aws_s3_object" "vms-list-json" {
  bucket = var.bucket_name
  key    = "infrastructure/vms.json"
  source = "vms.json" # use './build docs' to generate it
  etag = filemd5("vms.json")
  content_type = "application/json"
}

resource "aws_s3_object" "vms-list-html" {
  bucket = var.bucket_name
  key    = "infrastructure/vms.html"
  source = "vms.html" # use './build docs' to generate it
  etag = filemd5("vms.html")
  content_type = "text/html"
}

