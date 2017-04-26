output "key-pair-name" {
  value = "${openstack_compute_keypair_v2.default-key.name}"
}

output "secgroup-ssh-name" {
  value = "${openstack_compute_secgroup_v2.ssh-icmp-secgroup.name}"
}

output "secgroup-http-name" {
  value = "${openstack_compute_secgroup_v2.https-secgroup.name}"
}

output "network-id" {
  value = "${openstack_networking_network_v2.private-net.id}"
}
