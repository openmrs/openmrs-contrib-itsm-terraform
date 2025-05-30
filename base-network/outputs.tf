output "key-pair-name" {
  value = openstack_compute_keypair_v2.default-key.name
}

output "secgroup-ssh-name" {
  value = openstack_networking_secgroup_v2.ssh-icmp-secgroup.name
}

output "secgroup-http-name" {
  value = openstack_networking_secgroup_v2.https-secgroup.name
}

output "secgroup-bamboo-remote-agent-name" {
  value = openstack_networking_secgroup_v2.bamboo-remote-agent-secgroup.name
}

output "secgroup-bamboo-remote-agent-id" {
  value = openstack_networking_secgroup_v2.bamboo-remote-agent-secgroup.id
}

output "secgroup-ldap-name" {
  value = openstack_networking_secgroup_v2.ldap-secgroup.name
}

output "secgroup-ldap-id" {
  value = openstack_networking_secgroup_v2.ldap-secgroup.id
}

output "secgroup-database-name" {
  value = openstack_networking_secgroup_v2.database-secgroup.name
}

output "secgroup-database-id" {
  value = openstack_networking_secgroup_v2.database-secgroup.id
}

output "network-id" {
  value = {
    v2 = openstack_networking_network_v2.private-net.id
  }
}

output "backup-bucket-name" {
  value = aws_s3_bucket.automatic-backups.bucket
}

output "backup-bucket-arn" {
  value = aws_s3_bucket.automatic-backups.arn
}

