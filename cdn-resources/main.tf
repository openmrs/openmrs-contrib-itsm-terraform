# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "cdn-resources.tfstate"
  }
}


resource "aws_s3_bucket" "cdn-resources-s3" {
  bucket = var.bucket_name
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"AllowCloudFrontServicePrincipalReadOnly",
      "Effect":"Allow",
      "Principal": "*",
      "Action":"s3:GetObject",
      "Resource":["arn:aws:s3:::${var.bucket_name}/*"]
    }
  ]
}
POLICY

  tags = {
    Terraform = "cdn-resources"
  }
  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_s3_bucket_website_configuration" "cdn-resources-website" {
  bucket = aws_s3_bucket.cdn-resources-s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.cdn-resources-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "cdn-resources-controls" {
  bucket = aws_s3_bucket.cdn-resources-s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cdn-resources-block" {
  bucket = aws_s3_bucket.cdn-resources-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.cdn-resources-controls,
    aws_s3_bucket_public_access_block.cdn-resources-block,
  ]

  bucket = aws_s3_bucket.cdn-resources-s3.id
  acl    = "public-read"
}


resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.cdn-resources-s3.website_endpoint
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
  aliases             = ["cdn.openmrs.org", "assets.openmrs.org"]
  default_root_object = "index.html"
  tags = {
    Terraform = "cdn-resources"
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

resource "dme_dns_record" "cdn-dns" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "cdn"
  type      = "CNAME"
  value     = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}."
  ttl       = 300
}

resource "dme_dns_record" "assets-dns" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = "assets"
  type      = "CNAME"
  value     = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}."
  ttl       = 300
}

resource "aws_iam_user" "bamboo-user" {
  name = "bamboo-cdn-upload"
}

resource "aws_iam_access_key" "bamboo-user-key" {
  user = aws_iam_user.bamboo-user.name
}

resource "aws_iam_user_policy" "bamboo-user-policy" {
  name   = "upload_cdn"
  user   = aws_iam_user.bamboo-user.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.cdn-resources-s3.arn}"]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.cdn-resources-s3.arn}/*"
    }
  ]
}
EOF

}
