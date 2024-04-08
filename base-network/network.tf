# ----------------------------------------------------------------------------------------------------------------------
# Manages a V2 keypair resource within OpenStack
# ----------------------------------------------------------------------------------------------------------------------

resource "openstack_compute_keypair_v2" "default-key" {
  name       = "${var.project_name}-terraform-key"
  public_key = file("${var.ssh_key_file_v2}.pub")
}

# ----------------------------------------------------------------------------------------------------------------------
# Manages a V2 Neutron network resource within OpenStack
# ----------------------------------------------------------------------------------------------------------------------

resource "openstack_networking_network_v2" "private-net" {
  name           = "${var.project_name}-terraform-private"
  admin_state_up = "true"
  lifecycle {
    prevent_destroy = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Manages a V2 Neutron subnet resource within OpenStack
# ----------------------------------------------------------------------------------------------------------------------

resource "openstack_networking_subnet_v2" "default-subnet" {
  name       = "${var.project_name}-terraform-private-subnet"
  network_id = openstack_networking_network_v2.private-net.id
  cidr       = "10.0.2.0/24"
  ip_version = 4
  lifecycle {
    prevent_destroy = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Manages a V2 router resource within OpenStack
# ----------------------------------------------------------------------------------------------------------------------

resource "openstack_networking_router_v2" "default-router" {
  name                = "${var.project_name}-terraform-router"
  admin_state_up      = "true"
  external_network_id = var.external_gateway
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_router_interface_v2" "subnet-route" {
  router_id = openstack_networking_router_v2.default-router.id
  subnet_id = openstack_networking_subnet_v2.default-subnet.id
  lifecycle {
    prevent_destroy = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create V2 neutron security group rule and manage resource within OpenStack
# ----------------------------------------------------------------------------------------------------------------------

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
  lifecycle {
    prevent_destroy = true
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_secgroup_v2" "bamboo-remote-agent-secgroup" {
  name        = "${var.project_name}-bamboo-remote-agent"
  description = "Default bamboo-remote-agent group (terraform)."
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_secgroup_v2" "ldap-secgroup" {
  name        = "${var.project_name}-ldap"
  description = "Default group to contact ldap (terraform)."
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_secgroup_v2" "database-secgroup" {
  name        = "${var.project_name}-database"
  description = "Default group to contact database (terraform)."
  lifecycle {
    prevent_destroy = true
  }
}

