output "ocl_access_key_id" {
  value = "${aws_iam_access_key.ocl-user-key.id}"
}

output "ocl_access_key_secret" {
  value = "${aws_iam_access_key.ocl-user-key.secret}"
}

output "ocl_access_key_id_adhoc" {
  value = "${aws_iam_access_key.ocl-user-key-adhoc.id}"
}

output "ocl_access_key_secret_adhoc" {
  value = "${aws_iam_access_key.ocl-user-key-adhoc.secret}"
}


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
  value = "${formatlist("%s.%s", var.dns_cnames, var.main_domain_dns)}"
}

output "dns_manual_entries" {
  value = ["demo.openconceptlab.org", "api.demo.openconceptlab.org", "flower.demo.openconceptlab.org","staging.openconceptlab.org", "api.staging.openconceptlab.org", "flower.staging.openconceptlab.org"]
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

output "description" {
  value = "${var.description}"
}
