provider "openstack" {
}

## node: orbit
resource "openstack_compute_instance_v2" "orbit" {
  name            = "orbit"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "44"
  key_pair        = "id_rsa"
  security_groups = ["default"]

  network {
    name = "red de sergio.ferrete"
  }
}

# get float ip from pool
# resource "openstack_networking_floatingip_v2" "getfip_1" {
#   pool = "ext-net"
# }

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "172.22.201.108"
  # associate new float ip requested to the pool
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

# Necesita el initiator iSCSI
# resource "openstack_blockstorage_volume_attach_v2" "va_1" {
#   volume_id = "${openstack_blockstorage_volume_v2.openstack.id}"
#   device = "auto"
#   host_name = "orbit"
#   ip_address = "10.0.0.16"
# }

# node: mint
resource "openstack_compute_instance_v2" "mint" {
  name            = "mint"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "44"
  key_pair        = "id_rsa"
  security_groups = ["default"]

  network {
    name = "red de sergio.ferrete"
  }
}

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_2" {
  floating_ip = "172.22.201.111"
  instance_id = "${openstack_compute_instance_v2.mint.id}"
}

# node: boomer
resource "openstack_compute_instance_v2" "boomer" {
  name            = "boomer"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "44"
  key_pair        = "id_rsa"
  security_groups = ["default"]

  network {
    name = "red de sergio.ferrete"
  }
}

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_3" {
  floating_ip = "172.22.200.207"
  instance_id = "${openstack_compute_instance_v2.boomer.id}"
}
