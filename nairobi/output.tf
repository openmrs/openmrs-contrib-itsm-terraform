output "ocl_access_key_id" {
  value = "${aws_iam_access_key.ocl-user-key.id}"
}

output "ocl_access_key_secret" {
  value = "${aws_iam_access_key.ocl-user-key.secret}"
}

output "backup_access_key_id" {
  value = "${module.single-machine.user_access_key_id}"
}

output "backup_access_key_secret" {
  value = "${module.single-machine.user_access_key_secret}"
}
