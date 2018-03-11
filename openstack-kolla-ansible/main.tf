provider "openstack" {
}

## Internal network
resource "openstack_networking_network_v2" "interna-openstack" {
  name           = "interna-openstack"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet-openstack" {
  name       = "subnet-openstack"
  network_id = "${openstack_networking_network_v2.interna-openstack.id}"
  cidr       = "192.168.200.0/24"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "openstack-secgroup" {
  name        = "openstack"
  description = "Sec Group for openstack deployment"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_secgroup_rule_v2" "openstack-local-trafic" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_compute_secgroup_v2.openstack-secgroup.id}"
  remote_group_id = "${openstack_compute_secgroup_v2.openstack-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "openstack-remote-trafic" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_compute_secgroup_v2.openstack-secgroup.id}"
  remote_group_id = "84865709-76a7-4dd8-9807-2d10481e88ea"
}

resource "openstack_networking_secgroup_rule_v2" "default-remote-trafic" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "84865709-76a7-4dd8-9807-2d10481e88ea"
  remote_group_id = "${openstack_compute_secgroup_v2.openstack-secgroup.id}"
}

resource "openstack_networking_port_v2" "orbit_int_port" {
  # name               = "port_1"
  network_id         = "${openstack_networking_network_v2.interna-openstack.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.openstack-secgroup.id}"]
  allowed_address_pairs {
    ip_address = "10.0.0.0/24"
  }
  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.subnet-openstack.id}"
    "ip_address" = "192.168.200.10"
  }
}

# Network "Red de sergio.ferrete"
resource "openstack_networking_port_v2" "orbit_ext_port" {
  # name               = "port_1"
  network_id         = "0276f065-e76f-4ad9-9826-5c3f01375492"
  admin_state_up     = "true"
  security_group_ids = ["84865709-76a7-4dd8-9807-2d10481e88ea"]

  allowed_address_pairs {
    ip_address = "192.168.200.0/24"
  }
  fixed_ip {
    "subnet_id"  = "4b96837b-dcd3-4089-aad8-26f6a126c89f"
    "ip_address" = "10.0.0.30"
  }
}


## node: orbit, CONTROLLER
resource "openstack_compute_instance_v2" "orbit" {
  name            = "orbit"
  image_id        = "0dc7dc47-d3b6-43fa-ba67-0d3242f948f3"
  flavor_id       = "44" # 4G RAM
  key_pair        = "id_rsa"
  security_groups = ["default", "${openstack_compute_secgroup_v2.openstack-secgroup.name}"]

  network {
    name = "red de sergio.ferrete"
    port = "${openstack_networking_port_v2.orbit_ext_port.id}"
  }

  network {
    port = "${openstack_networking_port_v2.orbit_int_port.id}"
  }
}

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "172.22.201.108"
  instance_id = "${openstack_compute_instance_v2.orbit.id}"
}


# node: mint, COMPUTE node
resource "openstack_networking_port_v2" "mint_int_port" {
  # name               = "port_1"
  network_id         = "${openstack_networking_network_v2.interna-openstack.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.openstack-secgroup.id}"]

  allowed_address_pairs {
    ip_address = "10.0.0.0/24"
  }
  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.subnet-openstack.id}"
    "ip_address" = "192.168.200.20"
  }
}

# Network "Red de sergio.ferrete"
resource "openstack_networking_port_v2" "mint_ext_port" {
  # name               = "port_1"
  network_id         = "0276f065-e76f-4ad9-9826-5c3f01375492"
  admin_state_up     = "true"
  security_group_ids = ["84865709-76a7-4dd8-9807-2d10481e88ea"]

  allowed_address_pairs {
    ip_address = "192.168.200.0/24"
  }
  fixed_ip {
    "subnet_id"  = "4b96837b-dcd3-4089-aad8-26f6a126c89f"
    "ip_address" = "10.0.0.31"
  }
}

resource "openstack_networking_port_v2" "mint_ext_port2" {
  # name               = "port_1"
  network_id         = "0276f065-e76f-4ad9-9826-5c3f01375492"
  admin_state_up     = "true"
  security_group_ids = ["84865709-76a7-4dd8-9807-2d10481e88ea"]

  allowed_address_pairs {
    ip_address = "192.168.200.0/24"
  }
  fixed_ip {
    "subnet_id"  = "4b96837b-dcd3-4089-aad8-26f6a126c89f"
    "ip_address" = "10.0.0.100"
  }
}

resource "openstack_compute_instance_v2" "mint" {
  name            = "mint"
  image_id        = "0dc7dc47-d3b6-43fa-ba67-0d3242f948f3"
  flavor_id       = "16" # 8G RAM
  key_pair        = "id_rsa"
  security_groups = ["default", "${openstack_compute_secgroup_v2.openstack-secgroup.name}"]

  network {
    name = "red de sergio.ferrete"
    port = "${openstack_networking_port_v2.mint_ext_port.id}"
  }
  network {
    port = "${openstack_networking_port_v2.mint_int_port.id}"
  }
  network {
    name = "red de sergio.ferrete"
    port = "${openstack_networking_port_v2.mint_ext_port2.id}"
  }


}

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_2" {
  floating_ip = "172.22.201.111"
  instance_id = "${openstack_compute_instance_v2.mint.id}"
}
# create new volume, not attached
resource "openstack_blockstorage_volume_v2" "cinder_vol" {
  name        = "cinder_vol"
  description = "Kolla-ansible conder_vol"
  size        = 30
}

# attach volume to mint
resource "openstack_compute_volume_attach_v2" "attachedmint" {
  instance_id = "${openstack_compute_instance_v2.mint.id}"
  volume_id = "${openstack_blockstorage_volume_v2.cinder_vol.id}"
}
