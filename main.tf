resource "openstack_compute_instance_v2" "orbit" {
  name            = "orbit"
  image_id        = "f67e34fb-108d-4418-9a49-4a2dbde5a8f1"
  flavor_id       = "11"
  key_pair        = "id_rsa"
  security_groups = ["default"]

  metadata {
    this = "that"
  }

  network {
    name = "my_network"
  }
}
