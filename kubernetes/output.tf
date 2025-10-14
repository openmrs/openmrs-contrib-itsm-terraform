# output "backup_access_key_id" {
#   value = "${module.single-machine.backup_access_key_id}"
# }
#
# output "backup_access_key_secret" {
#   value = "${module.single-machine.backup_access_key_secret}"
#   sensitive = true
# }

output "kubernetes_cluster_id" {
  value = openstack_containerinfra_cluster_v1.kubernetes.id
}

output "kubernetes_master" {
  value = openstack_containerinfra_cluster_v1.kubernetes.master_addresses
}

output "kubernetes_dashboard_token" {
  value     = kubernetes_secret.kubernetes-dashboard.data["token"]
  sensitive = true
}