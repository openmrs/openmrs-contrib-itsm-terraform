resource "openstack_compute_keypair_v2" "default-key-iu" {
  name       = "${var.project_name}-terraform-key"
  public_key = file("${var.ssh_key_file}.pub")
  provider   = openstack.iu
}

resource "openstack_networking_network_v2" "private-net-iu" {
  name           = "${var.project_name}-terraform-private"
  admin_state_up = "true"
  provider       = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_subnet_v2" "default-subnet-iu" {
  name       = "${var.project_name}-terraform-private-subnet"
  network_id = openstack_networking_network_v2.private-net-iu.id
  cidr       = "10.0.1.0/25"
  ip_version = 4
  provider   = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_router_v2" "default-router-iu" {
  name                = "${var.project_name}-terraform-router"
  admin_state_up      = "true"
  external_network_id = var.external_gateway_iu
  provider            = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_router_interface_v2" "subnet-route-iu" {
  router_id = openstack_networking_router_v2.default-router-iu.id
  subnet_id = openstack_networking_subnet_v2.default-subnet-iu.id
  provider  = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_secgroup_v2" "ssh-icmp-secgroup-iu" {
  name        = "${var.project_name}-ssh-icmp"
  description = "Allow SSH and icmp from anywhere (terraform)."
  provider    = openstack.iu
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_secgroup_v2" "https-secgroup-iu" {
  name        = "${var.project_name}-https"
  description = "Allow http/s from anywhere (terraform)."
  provider    = openstack.iu
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_secgroup_v2" "bamboo-remote-agent-secgroup-iu" {
  name        = "${var.project_name}-bamboo-remote-agent"
  description = "Default bamboo-remote-agent group (terraform)."
  provider    = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_secgroup_v2" "ldap-secgroup-iu" {
  name        = "${var.project_name}-ldap"
  description = "Default group to contact ldap (terraform)."
  provider    = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_secgroup_v2" "database-secgroup-iu" {
  name        = "${var.project_name}-database"
  description = "Default group to contact database (terraform)."
  provider    = openstack.iu
  lifecycle {
    prevent_destroy = true
  }
}

