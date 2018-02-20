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

resource "openstack_networking_secgroup_rule_v2" "permit-local-trafic" {
  direction         = "ingress"
  ethertype         = "IPv4"
  # protocol          = "tcp"
  # port_range_min    = 22
  # port_range_max    = 22
  # remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_compute_secgroup_v2.openstack-secgroup.id}"
  remote_group_id = "${openstack_compute_secgroup_v2.openstack-secgroup.id}"
}

resource "openstack_networking_port_v2" "orbit_port" {
  # name               = "port_1"
  network_id         = "${openstack_networking_network_v2.interna-openstack.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.openstack-secgroup.id}"]

  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.subnet-openstack.id}"
    "ip_address" = "192.168.200.10"
  }
}

# Network "Red de sergio.ferrete"
resource "openstack_networking_port_v2" "orbit_port_eth0" {
  # name               = "port_1"
  network_id         = "0276f065-e76f-4ad9-9826-5c3f01375492"
  admin_state_up     = "true"
  security_group_ids = ["84865709-76a7-4dd8-9807-2d10481e88ea"]

  fixed_ip {
    "subnet_id"  = "4b96837b-dcd3-4089-aad8-26f6a126c89f"
    "ip_address" = "10.0.0.30"
  }
}


## node: orbit, CONTROLLER
resource "openstack_compute_instance_v2" "orbit" {
  name            = "orbit"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "45" # 4G RAM
  key_pair        = "id_rsa"
  security_groups = ["default", "${openstack_compute_secgroup_v2.openstack-secgroup.name}"]

  network {
    name = "red de sergio.ferrete"
    port = "${openstack_networking_port_v2.orbit_port_eth0.id}"
  }

  network {
    port = "${openstack_networking_port_v2.orbit_port.id}"
  }
}

# get float ip from pool
# resource "openstack_networking_floatingip_v2" "getfip_1" {
#   pool = "ext-net"
# }

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "172.22.201.108"
  # associate new float ip requested from the pool
  # floating_ip = "${openstack_networking_floatingip_v2.getfip_1.address}"
  instance_id = "${openstack_compute_instance_v2.orbit.id}"
}

# create new volume, not attached
resource "openstack_blockstorage_volume_v2" "openstack" {
  name        = "openstack"
  description = "Volume create by terraform"
  size        = 5
}

# attach volume to orbit
resource "openstack_compute_volume_attach_v2" "attachedtorobit" {
  instance_id = "${openstack_compute_instance_v2.orbit.id}"
  volume_id = "${openstack_blockstorage_volume_v2.openstack.id}"
}


# node: mint, COMPUTE node

resource "openstack_networking_port_v2" "mint_port" {
  # name               = "port_1"
  network_id         = "${openstack_networking_network_v2.interna-openstack.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.openstack-secgroup.id}"]

  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.subnet-openstack.id}"
    "ip_address" = "192.168.200.20"
  }
}

# Network "Red de sergio.ferrete"
resource "openstack_networking_port_v2" "mint_port_eth0" {
  # name               = "port_1"
  network_id         = "0276f065-e76f-4ad9-9826-5c3f01375492"
  admin_state_up     = "true"
  security_group_ids = ["84865709-76a7-4dd8-9807-2d10481e88ea"]

  fixed_ip {
    "subnet_id"  = "4b96837b-dcd3-4089-aad8-26f6a126c89f"
    "ip_address" = "10.0.0.31"
  }
}

resource "openstack_compute_instance_v2" "mint" {
  name            = "mint"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "45" # 8G RAM
  key_pair        = "id_rsa"
  security_groups = ["default", "${openstack_compute_secgroup_v2.openstack-secgroup.name}"]

  network {
    name = "red de sergio.ferrete"
    port = "${openstack_networking_port_v2.mint_port_eth0.id}"
  }
  network {
    port = "${openstack_networking_port_v2.mint_port.id}"
  }

}

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_2" {
  floating_ip = "172.22.201.111"
  instance_id = "${openstack_compute_instance_v2.mint.id}"
}



#
# # node: boomer

resource "openstack_networking_port_v2" "boomer_port" {
  # name               = "port_1"
  network_id         = "${openstack_networking_network_v2.interna-openstack.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.openstack-secgroup.id}"]

  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.subnet-openstack.id}"
    "ip_address" = "192.168.200.5"
  }
}

resource "openstack_compute_instance_v2" "boomer" {
  name            = "boomer"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "13" # 512 RAM
  key_pair        = "id_rsa"
  security_groups = ["default","${openstack_compute_secgroup_v2.openstack-secgroup.name}"]

  network {
    name = "red de sergio.ferrete"
  }
  network {
    port = "${openstack_networking_port_v2.boomer_port.id}"
  }
}

# boomer float IP
resource "openstack_compute_floatingip_associate_v2" "fip_3" {
  floating_ip = "172.22.200.207"
  instance_id = "${openstack_compute_instance_v2.boomer.id}"
}
