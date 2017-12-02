resource "openstack_compute_floatingip_v2" "ip" {
  pool       = "${var.pool}"
}

resource "openstack_compute_instance_v2" "vm" {
  name            = "${var.project_name}-${var.hostname}"
  image_id        = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${data.terraform_remote_state.base.key-pair-name}"
  security_groups = ["${
    compact(
      concat(
          list(
            data.terraform_remote_state.base.secgroup-ssh-name,
            var.allow_web? data.terraform_remote_state.base.secgroup-http-name:""
          ),
          var.extra_security_groups
      )
    )
  }"]

  network {
    uuid = "${data.terraform_remote_state.base.network-id[var.region]}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_vm" {
  floating_ip = "${openstack_compute_floatingip_v2.ip.address}"
  instance_id = "${openstack_compute_instance_v2.vm.id}"
}

resource "openstack_blockstorage_volume_v2" "data_volume" {
  count  = "${var.has_data_volume}"
  name   = "${var.project_name}-data_volume"
  size   = "${var.data_volume_size}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "attach_data_volume" {
  count       = "${var.has_data_volume}"
  depends_on  = ["openstack_blockstorage_volume_v2.data_volume", "openstack_compute_instance_v2.vm"]
  instance_id = "${openstack_compute_instance_v2.vm.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.data_volume.id}"
}

resource "null_resource" "mount_data_volume" {
  count       = "${var.has_data_volume}"
  depends_on  = ["openstack_compute_floatingip_associate_v2.fip_vm", "openstack_compute_volume_attach_v2.attach_data_volume"]
  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/data_volume.sh"
    destination = "/tmp/data_volume.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/data_volume.sh",
      "/tmp/data_volume.sh",
    ]
  }
}

resource "null_resource" "setup-dns" {
  depends_on  = ["null_resource.mount_data_volume"]
  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/configure-dns.sh"
    destination = "/tmp/configure-dns.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/configure-dns.sh",
      "sudo /tmp/configure-dns.sh",
    ]
  }
}

resource "null_resource" "upgrade" {
  count = "${var.update_os}"
  depends_on = ["null_resource.setup-dns"]
  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }


  provisioner "file" {
    source      = "../conf/provisioning/upgrade.sh"
    destination = "/tmp/upgrade.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/upgrade.sh",
      "sudo /tmp/upgrade.sh",
    ]
  }
}

resource "null_resource" "add_github_key" {
  count      = "${var.add_github_key}"
  depends_on = ["null_resource.upgrade"]

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/github/github.key"
    destination = "/tmp/github_id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "sudo mkdir -p /root/.ssh",
      "sudo mv /tmp/github_id_rsa /root/.ssh/github_id_rsa",
      "sudo chmod 600 /root/.ssh/github_id_rsa"
    ]
  }
}

# ssh/scp from terraform stops working after this step
resource "null_resource" "ansible" {
  count      = "${var.use_ansible}"
  depends_on = ["null_resource.add_github_key", "null_resource.upgrade"]
  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/github/github.key"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "../conf/provisioning/ansible"
    destination = "/root/.gnupg"
  }

  provisioner "file" {
    source      = "../conf/provisioning/ansible.sh"
    destination = "/tmp/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "yes | DEBIAN_FRONTEND=noninteractive aptdcon --hide-terminal -i git-crypt python-dev libffi-dev",
      "chmod a+x /tmp/ansible.sh",
      "/tmp/ansible.sh \"${var.ansible_repo}\" ${var.ansible_inventory} ${var.hostname}",
      "rm -rf /tmp/ansible",
      "rm /root/.ssh/id_rsa",
      "rm -rf /root/.gnupg"
    ]
  }
}
