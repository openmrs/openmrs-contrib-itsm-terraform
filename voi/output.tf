
output "backup_access_key_id" {
  value = "${module.single-machine.backup_access_key_id}"
}

output "backup_access_key_secret" {
  value = "${module.single-machine.backup_access_key_secret}"
}

output "ip_address" {
  value = "${module.single-machine.address}"
}

output "dns_entries" {
  value = "${concat( formatlist("%s.%s", var.dns_cnames, var.main_domain_dns), list(var.dns_domain, format("%s.%s", dme_record.short-dns-wildcard.name, var.dns_domain)) )}"
}

output "ansible_inventory" {
  value = "${var.ansible_inventory}"
}

output "has_data_volume" {
  value = "${var.has_data_volume}"
}

output "data_volume_size" {
  value = "${var.data_volume_size}"
}

output "has_backup" {
  value = "${var.has_backup}"
}

output "flavor" {
  value = "${var.flavor}"
}

output "region" {
  value = "${var.region}"
}

output "provisioner" {
  value = "terraform"
}
