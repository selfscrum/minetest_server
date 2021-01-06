//   root_block_device {
//     volume_type           = var.root_volume_type
//     volume_size           = var.root_volume_size
//     delete_on_termination = var.root_volume_delete_on_termination
//   }

resource "hcloud_server" "minetest" {
  name        = var.cluster_name
  image       = var.image
  server_type = var.server_type
  location    = var.location
  labels      = var.labels
  ssh_keys    = [ var.ssh_key ]
  user_data   = var.user_data
}

/*

resource "hcloud_server_network" "internal_consul" {
  count = var.cluster_size
  network_id = var.network_id
  server_id  = element(hcloud_server.consul.*.id, count.index)
  # this split is a temporary hack until Hetzner has "real" subnet objects and not just a shadow API. 
  # the subnet id is a combination of network id and subnet CIDR, e.g. "123456-10.0.2.0/24")
  ip = cidrhost(split("-", var.private_subnet_id)[1], 10+count.index)
}

*/