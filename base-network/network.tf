resource "openstack_compute_keypair_v2" "default-key" {
  name       = "${var.project_name}-terraform-key"
  public_key = file("${var.ssh_key_file_v2}.pub")
  provider   = openstack.v2
}

resource "openstack_networking_network_v2" "private-net" {
  name           = "${var.project_name}-terraform-private"
  admin_state_up = "true"
  provider       = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_subnet_v2" "default-subnet" {
  name       = "${var.project_name}-terraform-private-subnet"
  network_id = openstack_networking_network_v2.private-net.id
  cidr       = "10.0.2.0/24"
  ip_version = 4
  provider   = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_router_v2" "default-router" {
  name                = "${var.project_name}-terraform-router"
  admin_state_up      = "true"
  external_network_id = var.external_gateway
  provider            = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_router_interface_v2" "subnet-route" {
  router_id = openstack_networking_router_v2.default-router.id
  subnet_id = openstack_networking_subnet_v2.default-subnet.id
  provider  = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_secgroup_v2" "ssh-icmp-secgroup" {
  name        = "${var.project_name}-ssh-icmp"
  description = "Allow SSH and icmp from anywhere (terraform)."
  provider    = openstack.v2
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

resource "openstack_compute_secgroup_v2" "https-secgroup" {
  name        = "${var.project_name}-https"
  description = "Allow http/s from anywhere (terraform)."
  provider    = openstack.v2
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

resource "openstack_compute_secgroup_v2" "bamboo-remote-agent-secgroup" {
  name        = "${var.project_name}-bamboo-remote-agent"
  description = "Default bamboo-remote-agent group (terraform)."
  provider    = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_secgroup_v2" "ldap-secgroup" {
  name        = "${var.project_name}-ldap"
  description = "Default group to contact ldap (terraform)."
  provider    = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_secgroup_v2" "database-secgroup" {
  name        = "${var.project_name}-database"
  description = "Default group to contact database (terraform)."
  provider    = openstack.v2
  lifecycle {
    prevent_destroy = true
  }
}

