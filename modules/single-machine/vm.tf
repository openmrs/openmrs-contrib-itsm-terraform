resource "openstack_compute_floatingip_v2" "ip" {
  pool = var.pool
}

resource "openstack_compute_instance_v2" "vm" {
  name        = "${var.project_name}-${var.hostname}"
  image_id    = var.image
  flavor_name = var.flavor
  power_state = var.power_state
  key_pair    = data.terraform_remote_state.base.outputs.key-pair-name
  security_groups = compact(
    concat(
      list(
        data.terraform_remote_state.base.outputs.secgroup-ssh-name,
        var.allow_web ? data.terraform_remote_state.base.outputs.secgroup-http-name : ""
      ),
      var.extra_security_groups
    )
  )


  network {
    uuid = data.terraform_remote_state.base.outputs.network-id[var.region]
  }

  # Jetstream has a tendency of deprecating images and not allowing new ones
  # Not recreating machines just because we changed the image ID
  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_vm" {
  floating_ip = openstack_compute_floatingip_v2.ip.address
  instance_id = openstack_compute_instance_v2.vm.id
}

resource "openstack_blockstorage_volume_v3" "data_volume" {
  count = var.has_data_volume ? 1 : 0
  name  = "${var.project_name}-data_volume"
  size  = var.data_volume_size

  # this cannot be a variable!!!!!!
  # https://github.com/hashicorp/terraform/issues/3116
  lifecycle {
    # prevent_destroy = false
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "attach_data_volume" {
  count       = var.has_data_volume ? 1 : 0
  depends_on  = [openstack_blockstorage_volume_v3.data_volume, openstack_compute_instance_v2.vm]
  instance_id = openstack_compute_instance_v2.vm.id
  volume_id   = openstack_blockstorage_volume_v3.data_volume[count.index].id
}

resource "null_resource" "mount_data_volume" {
  count      = var.has_data_volume ? 1 : 0
  depends_on = [openstack_compute_floatingip_associate_v2.fip_vm, openstack_compute_volume_attach_v2.attach_data_volume]
  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
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
      "sudo /tmp/data_volume.sh",
    ]
  }
}

resource "null_resource" "upgrade" {
  count      = var.update_os ? 1 : 0
  depends_on = [openstack_compute_floatingip_associate_v2.fip_vm, openstack_compute_volume_attach_v2.attach_data_volume]
  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
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
  count      = var.leave_git_clone_creds ? 1 : 0
  depends_on = [null_resource.upgrade]

  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
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


resource "null_resource" "add_gitcrypt_key" {
  count      = var.leave_git_clone_creds ? 1 : 0
  depends_on = [null_resource.upgrade]

  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
  }

  provisioner "file" {
    source      = "../conf/provisioning/ansible"
    destination = "/tmp/ansible-gnupg"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "sudo mv /tmp/ansible-gnupg /root/ansible-gnupg",
      "sudo chown -R root:root /root/ansible-gnupg/"
    ]
  }
}

data "template_file" "provisioning_file" {
  template = templatefile("${path.module}/templates/provisioning_facts.tpl",
    {
      ansible_inventory = var.ansible_inventory
      region            = var.region
      has_backup        = var.has_backup
  })
}


resource "null_resource" "copy_facts" {
  count      = var.copy_ansible_facts ? 1 : 0
  depends_on = [null_resource.upgrade]

  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
  }

  provisioner "file" {
    content     = data.template_file.provisioning_file.rendered
    destination = "/tmp/provisioning.fact"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "sudo mkdir -p /etc/ansible/facts.d/",
      "sudo mv /tmp/provisioning.fact /etc/ansible/facts.d/",
      "sudo chown -R root:root /etc/ansible/facts.d/"
    ]
  }
}

data "template_file" "provisioning_file_backup" {
  count = var.has_backup ? 1 : 0
  template = templatefile("${path.module}/templates/provisioning_aws_facts.tpl", {
    aws_access_key_id     = aws_iam_access_key.backup-user-key[count.index].id
    aws_secret_access_key = aws_iam_access_key.backup-user-key[count.index].secret
  })
}

resource "null_resource" "copy_facts_backups" {
  count      = var.has_backup ? 1 : 0
  depends_on = [null_resource.copy_facts]

  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
  }

  provisioner "file" {
    content     = data.template_file.provisioning_file_backup[count.index].rendered
    destination = "/tmp/aws.fact"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "sudo mv /tmp/aws.fact /etc/ansible/facts.d/",
      "sudo chown -R root:root /etc/ansible/facts.d/"
    ]
  }
}

# ssh/scp from terraform stops working after this step
# global-variables need to use personal creds instead
resource "null_resource" "ansible" {
  count      = var.use_ansible ? 1 : 0
  depends_on = [null_resource.add_github_key, null_resource.add_gitcrypt_key, null_resource.copy_facts, null_resource.copy_facts_backups]
  connection {
    user        = var.ssh_username
    private_key = file(var.ssh_key_file)
    host        = openstack_compute_floatingip_v2.ip.address
  }

  provisioner "file" {
    source      = "../conf/provisioning/github/github.key"
    destination = "/tmp/ssh_id_rsa"
  }

  provisioner "file" {
    source      = "../conf/provisioning/ansible"
    destination = "/tmp/.gnupg"
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
      "chmod a+x /tmp/ansible.sh",
      "sudo mkdir -p /root/.ssh",
      "sudo mv /tmp/ssh_id_rsa /root/.ssh/id_rsa",
      "sudo chown -R root:root /root/.ssh",
      "sudo rm -rf /root/.gnupg",
      "sudo mv /tmp/.gnupg /root/.gnupg",
      "sudo chown -R root:root /root/.gnupg",
      "sudo /tmp/ansible.sh \"${var.ansible_repo}\" ${var.ansible_inventory} ${var.hostname}"
    ]
  }
}
