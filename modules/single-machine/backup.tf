resource "aws_iam_user" "backup-user" {
  count = var.has_backup ? 1 : 0
  name  = "backup-${var.hostname}"
}

resource "aws_iam_access_key" "backup-user-key" {
  count = var.has_backup ? 1 : 0
  user  = aws_iam_user.backup-user[count.index].name
}

resource "aws_iam_user_policy" "backup-user-policy" {
  count = var.has_backup ? 1 : 0
  name  = "backup_${var.hostname}"
  user  = aws_iam_user.backup-user[count.index].name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : [data.terraform_remote_state.base.outputs.backup-bucket-arn]
      },
      {
        "Action" : [
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        "Effect" : "Allow",
        "Resource" : "${data.terraform_remote_state.base.outputs.backup-bucket-arn}/${var.hostname}/*"
      }
    ]
  })
}
