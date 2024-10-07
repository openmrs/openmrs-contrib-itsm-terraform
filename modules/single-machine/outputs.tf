output "address" {
  value = openstack_networking_floatingip_v2.ip.address
}

output "private_address" {
  value = openstack_compute_instance_v2.vm.network.0.fixed_ip_v4
}

output "vm_name" {
  value = openstack_compute_instance_v2.vm.name
}

output "backup_access_key_id" {
  value = element(concat(aws_iam_access_key.backup-user-key.*.id, tolist([""])), 0)
}

output "backup_access_key_secret" {
  value = element(concat(aws_iam_access_key.backup-user-key.*.secret, tolist([""])), 0)
}

output "dns_entries" {
  value = [dme_dns_record.hostname.name, dme_dns_record.cnames.*.name]
}

output "private-dns" {
  value = element(concat(dme_dns_record.private_hostname.*.name, tolist([""])), 0)
}

output "power_state" {
  value = openstack_compute_instance_v2.vm.power_state
}
