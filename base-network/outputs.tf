output "key-pair-name" {
  value = openstack_compute_keypair_v2.default-key-tacc.name
}

output "secgroup-ssh-name" {
  value = openstack_compute_secgroup_v2.ssh-icmp-secgroup-tacc.name
}

output "secgroup-http-name" {
  value = openstack_compute_secgroup_v2.https-secgroup-tacc.name
}

output "secgroup-bamboo-remote-agent-name" {
  value = openstack_compute_secgroup_v2.bamboo-remote-agent-secgroup-tacc.name
}

output "secgroup-bamboo-remote-agent-id-iu" {
  value = openstack_compute_secgroup_v2.bamboo-remote-agent-secgroup-iu.id
}

output "secgroup-bamboo-remote-agent-id-tacc" {
  value = openstack_compute_secgroup_v2.bamboo-remote-agent-secgroup-tacc.id
}

output "secgroup-ldap-name" {
  value = openstack_networking_secgroup_v2.ldap-secgroup-tacc.name
}

output "secgroup-ldap-id-iu" {
  value = openstack_networking_secgroup_v2.ldap-secgroup-iu.id
}

output "secgroup-ldap-id-tacc" {
  value = openstack_networking_secgroup_v2.ldap-secgroup-tacc.id
}

output "secgroup-database-name" {
  value = openstack_networking_secgroup_v2.database-secgroup-tacc.name
}

output "secgroup-database-id-iu" {
  value = openstack_networking_secgroup_v2.database-secgroup-iu.id
}

output "secgroup-database-id-tacc" {
  value = openstack_networking_secgroup_v2.database-secgroup-tacc.id
}

output "network-id" {
  value = {
    tacc = openstack_networking_network_v2.private-net-tacc.id
    iu   = openstack_networking_network_v2.private-net-iu.id
  }
}

output "backup-bucket-name" {
  value = aws_s3_bucket.automatic-backups.bucket
}

output "backup-bucket-arn" {
  value = aws_s3_bucket.automatic-backups.arn
}

