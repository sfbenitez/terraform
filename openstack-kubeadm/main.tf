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

## node: trident
resource "openstack_compute_instance_v2" "trident" {
  name            = "trident"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "44"
  key_pair        = "id_rsa"
  security_groups = ["default"]

  network {
    name = "red de sergio.ferrete"
  }
}

# associate existing float IP
resource "openstack_compute_floatingip_associate_v2" "fip_4" {
  floating_ip = "172.22.200.116"
  # associate new float ip requested to the pool
  # floating_ip = "${openstack_networking_floatingip_v2.getfip_1.address}"
  instance_id = "${openstack_compute_instance_v2.trident.id}"
}

# create new volume, not attached
resource "openstack_blockstorage_volume_v2" "gluster_1" {
  name        = "gluster-1"
  description = "Volume create by terraform"
  size        = 5
}

# attach volume to orbit
resource "openstack_compute_volume_attach_v2" "attachedtotrident" {
  instance_id = "${openstack_compute_instance_v2.trident.id}"
  volume_id = "${openstack_blockstorage_volume_v2.gluster_1.id}"
}

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

# create new volume, not attached
resource "openstack_blockstorage_volume_v2" "gluster_2" {
  name        = "gluster-2"
  description = "Volume create by terraform"
  size        = 5
}

# attach volume to mint
resource "openstack_compute_volume_attach_v2" "attachedtomint" {
  instance_id = "${openstack_compute_instance_v2.mint.id}"
  volume_id = "${openstack_blockstorage_volume_v2.gluster_2.id}"
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

# create new volume, not attached
resource "openstack_blockstorage_volume_v2" "gluster_3" {
  name        = "gluster-3"
  description = "Volume create by terraform"
  size        = 5
}

# attach volume to boomer
resource "openstack_compute_volume_attach_v2" "attachedtoboomer" {
  instance_id = "${openstack_compute_instance_v2.boomer.id}"
  volume_id = "${openstack_blockstorage_volume_v2.gluster_3.id}"
}
