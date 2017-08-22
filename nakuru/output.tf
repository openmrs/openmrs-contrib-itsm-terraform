output "user_access_key_id" {
  value = "${aws_iam_access_key.ocl-user-key.id}"
}

output "user_access_key_secret" {
  value = "${aws_iam_access_key.ocl-user-key.secret}"
}
