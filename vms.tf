# resource "openstack_compute_floatingip_v2" "terraform" {
#   pool       = "${var.pool}"
#   depends_on = ["openstack_networking_router_interface_v2.terraform"]
# }

# resource "openstack_compute_instance_v2" "terraform" {
#   name            = "terraform"
#   image_name      = "${var.image}"
#   flavor_name     = "${var.flavor}"
#   key_pair        = "${openstack_compute_keypair_v2.terraform.name}"
#   security_groups = ["${openstack_compute_secgroup_v2.terraform.name}"]
#   floating_ip     = "${openstack_compute_floatingip_v2.terraform.address}"
#
#   network {
#     uuid = "${openstack_networking_network_v2.terraform.id}"
#   }
#
#   provisioner "remote-exec" {
#     connection {
#       user     = "${var.ssh_user_name}"
#       private_key = "${file(var.ssh_key_file)}"
#     }
#
#     inline = [
#       "sudo apt-get -y update",
#       "sudo apt-get -y install nginx",
#       "sudo service nginx start",
#     ]
#   }
#}
