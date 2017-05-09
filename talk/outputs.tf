output "user_access_key_id" {
  value = "${aws_iam_access_key.backup-user-key.id}"
}

output "user_access_key_secret" {
  value = "${aws_iam_access_key.backup-user-key.secret}"
}
