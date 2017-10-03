output "backup_access_key_id" {
  value = "${module.single-machine.user_access_key_id}"
}

output "backup_access_key_secret" {
  value = "${module.single-machine.user_access_key_secret}"
}
