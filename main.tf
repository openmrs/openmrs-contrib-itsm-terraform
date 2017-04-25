# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "basic-network-setup"
    region = "us-west-2"
  }
}

resource "openstack_compute_keypair_v2" "default-key" {
  name       = "${var.project_name}-terraform-key"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}
#
# resource "openstack_networking_network_v2" "terraform" {
#   name           = "terraform"
#   admin_state_up = "true"
# }
#
# resource "openstack_networking_subnet_v2" "terraform" {
#   name            = "terraform"
#   network_id      = "${openstack_networking_network_v2.terraform.id}"
#   cidr            = "10.0.0.0/24"
#   ip_version      = 4
#   dns_nameservers = ["8.8.8.8", "8.8.4.4"]
# }
#
# resource "openstack_networking_router_v2" "terraform" {
#   name             = "terraform"
#   admin_state_up   = "true"
#   external_gateway = "${var.external_gateway}"
# }
#
# resource "openstack_networking_router_interface_v2" "terraform" {
#   router_id = "${openstack_networking_router_v2.terraform.id}"
#   subnet_id = "${openstack_networking_subnet_v2.terraform.id}"
# }

resource "openstack_compute_secgroup_v2" "ssh-icmp-secgroup" {
  name        = "${var.project_name}-ssh-icmp"
  description = "Allow SSH and icmp from anywhere (terraform)."

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "https-secgroup" {
  name        = "${var.project_name}-https"
  description = "Allow http/s from anywhere (terraform)."

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

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
