module "network_lab" {
  source  = "tf-openstack-modules/networks/openstack"
  version = "0.1.0"

  router_id = openstack_networking_router_v2.router.id
  network = {
    name        = "osic-network-lab"
    subnet_name = "osic-devstack-subnet",
    cidr        = "10.0.0.0/24"
  }
  dns_ip = ["8.8.8.8", "8.8.4.4", "72.3.128.240", "72.3.128.241"]
}

resource "openstack_networking_router_v2" "router" {
  name                = "OSIC_SHARED_ROUTER_1"
  admin_state_up      = "true"
  external_network_id = var.external_gateway
}

resource "openstack_networking_floatingip_v2" "floatingip" {
  pool = var.floating_pool
}
