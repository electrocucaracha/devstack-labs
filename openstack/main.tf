terraform {
  required_providers {
    template = "~> 2.0"
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
  required_version = ">=1.51"
}

data "template_file" "devstack_postinstall_script" {
  template = file("${path.module}/../templates/devstack.tpl")
  vars = {
    password = "password"
  }
}

resource "openstack_compute_secgroup_v2" "devstack_secgroup" {
  name        = "osic-lab-devstack"
  description = "Security group for accessing devstack VMs from jumpbox"
  rule {
    from_port     = 22
    to_port       = 22
    ip_protocol   = "tcp"
    from_group_id = openstack_compute_secgroup_v2.jumpbox_secgroup.id
  }
  rule {
    from_port     = 80
    to_port       = 80
    ip_protocol   = "tcp"
    from_group_id = openstack_compute_secgroup_v2.jumpbox_secgroup.id
  }
  rule {
    from_port     = 6080
    to_port       = 6080
    ip_protocol   = "tcp"
    from_group_id = openstack_compute_secgroup_v2.jumpbox_secgroup.id
  }
}

resource "openstack_compute_instance_v2" "devstack" {
  count           = var.num_devstacks
  name            = "osic-devstack-${count.index + 1}"
  image_name      = var.image
  flavor_name     = var.flavor
  security_groups = [openstack_compute_secgroup_v2.devstack_secgroup.name]
  user_data       = data.template_file.devstack_postinstall_script.rendered

  network {
    uuid = module.network_lab.network.id
  }
}

resource "openstack_compute_secgroup_v2" "jumpbox_secgroup" {
  name        = "osic-lab-jumpbox"
  description = "Security group for accessing jumpbox from outside"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 80
    to_port     = 8080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "jumpbox" {
  name            = "osic-jumpbox"
  image_name      = var.image
  flavor_name     = var.flavor
  security_groups = [openstack_compute_secgroup_v2.jumpbox_secgroup.name]
  user_data       = file("${path.module}/../scripts/jumpbox.yml")

  network {
    uuid = module.network_lab.network.id
  }

  provisioner "local-exec" {
    command = "echo 'ssh -o PreferredAuthentications=password -L 6080:10.0.0.$1:6080 -L 8080:10.0.0.$1:80 -t osicer@${openstack_networking_floatingip_v2.floatingip.address} ssh stack@10.0.0.$1' > ssh_osic.sh"
  }
}

resource "openstack_compute_floatingip_associate_v2" "jumpbox" {
  floating_ip = openstack_networking_floatingip_v2.floatingip.address
  instance_id = openstack_compute_instance_v2.jumpbox.id
}

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
