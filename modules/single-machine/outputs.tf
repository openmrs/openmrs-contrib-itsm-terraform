output "address" {
  value = "${openstack_compute_floatingip_v2.ip.address}"
}

output "vm-name" {
  value = "${openstack_compute_instance_v2.vm.name}"
}

output "user_access_key_id" {
  value = "${aws_iam_access_key.backup-user-key.id}"
}

output "user_access_key_secret" {
  value = "${aws_iam_access_key.backup-user-key.secret}"
}
