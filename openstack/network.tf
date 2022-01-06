resource "openstack_networking_network_v2" "osic_network" {
  name = "osic-network-lab"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "devstack_subnet" {
  name = "osic-devstack-subnet"
  network_id = openstack_networking_network_v2.osic_network.id
  cidr = "10.0.0.0/24"
  ip_version = 4
  enable_dhcp = "true"
  dns_nameservers = ["8.8.8.8", "8.8.4.4", "72.3.128.240", "72.3.128.241"]
}

resource "openstack_networking_router_v2" "router" {
  name = "OSIC_SHARED_ROUTER_1"
  admin_state_up = "true"
  external_network_id = var.external_gateway
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.devstack_subnet.id
}

resource "openstack_networking_floatingip_v2" "floatingip" {
  pool = var.floating_pool
}
