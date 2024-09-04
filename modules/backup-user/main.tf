
# ---------------------------------------------------------------------
# any resources from the base stack
# ---------------------------------------------------------------------

data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}
resource "aws_iam_user" "backup-user" {
  name  = "backup-${var.hostname}"
}

resource "aws_iam_access_key" "backup-user-key" {
  user = aws_iam_user.backup-user.name
}

resource "aws_iam_user_policy" "backup-user-policy" {
  name  = "backup_${var.hostname}"
  user  = aws_iam_user.backup-user.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["s3:ListBucket"],
        "Resource": ["${data.terraform_remote_state.base.outputs.backup-bucket-arn}"]
      },
      {
        "Action": [
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        "Effect": "Allow",
        "Resource": "${data.terraform_remote_state.base.outputs.backup-bucket-arn}/${var.hostname}/*"
      }
    ]
  })
}
