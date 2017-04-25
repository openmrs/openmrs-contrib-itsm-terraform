output "address" {
  value = "${openstack_compute_floatingip_v2.ip.address}"
}

output "vm-name" {
  value = "${openstack_compute_instance_v2.vm.name}"
}
