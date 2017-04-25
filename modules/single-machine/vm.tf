# any resources from the base stack
data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}

resource "openstack_compute_floatingip_v2" "ip" {
  pool       = "${var.pool}"
}

resource "openstack_compute_instance_v2" "vm" {
  name            = "${var.project_name}-${var.hostname}"
  image_id        = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${data.terraform_remote_state.base.key-pair-name}"
  security_groups = [
    "${data.terraform_remote_state.base.secgroup-ssh-name}",
    "${data.terraform_remote_state.base.secgroup-http-name}"
  ]

  network {
    uuid = "${data.terraform_remote_state.base.network-id}"
  }

  # provisioner "remote-exec" {
  #   connection {
  #     user        = "${var.ssh_user_name}"
  #     private_key = "${file(var.ssh_key_file)}"
  #   }
  #
  #   inline = [
  #     "sudo apt-get -y update",
  #     "sudo apt-get -y install nginx",
  #   ]
  # }
}

resource "openstack_compute_floatingip_associate_v2" "fip_vm" {
  floating_ip = "${openstack_compute_floatingip_v2.ip.address}"
  instance_id = "${openstack_compute_instance_v2.vm.id}"
}
