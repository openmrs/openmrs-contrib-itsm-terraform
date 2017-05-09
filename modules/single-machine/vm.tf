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
}

resource "openstack_compute_floatingip_associate_v2" "fip_vm" {
  floating_ip = "${openstack_compute_floatingip_v2.ip.address}"
  instance_id = "${openstack_compute_instance_v2.vm.id}"
}

resource "null_resource" "provision" {
  depends_on = ["openstack_compute_floatingip_associate_v2.fip_vm"]
  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get -y update",
      "apt-get -o Dpkg::Options::=\"--force-confold\" --force-yes -y upgrade",
    ]
  }
}
