output "ocl_access_key_id" {
  value = "${aws_iam_access_key.ocl-user-key.id}"
}

output "ocl_access_key_secret" {
  value = "${aws_iam_access_key.ocl-user-key.secret}"
}


output "ip_address" {
  value = "${module.single-machine.address}"
}

output "dns_entries" {
  value = "${formatlist("%s.%s", var.dns_cnames, var.main_domain_dns)}"
}

output "dns_manual_entries" {
  value = ["qa.openconceptlab.org", "api.qa.openconceptlab.org", "flower.qa.openconceptlab.org"]
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
