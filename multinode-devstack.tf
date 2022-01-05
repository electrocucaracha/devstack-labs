resource "openstack_compute_secgroup_v2" "controller_devstack_secgroup" {
  name = "osic-lab-controller-devstack"
  description = "Security group for accessing controller from compute nodes"
  rule {
    from_port = 3306
    to_port = 3306
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 5672
    to_port = 5672
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 5000
    to_port = 5000
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 8774
    to_port = 8774
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 8776
    to_port = 8776
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 9696
    to_port = 9696
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

# Template for controller devstack installation
data "template_file" "controller_devstack_postinstall_script" {
  template = file("controller-devstack.tpl")
  vars {
    password = "secure"
  }
}

resource "openstack_compute_instance_v2" "controller_devstack" {
  name = "osic-devstack-controller"
  image_name = var.image
  flavor_name = var.flavor
  security_groups = [ openstack_compute_secgroup_v2.controller_devstack_secgroup.name, openstack_compute_secgroup_v2.devstack_secgroup.name ]
  user_data = data.template_file.controller_devstack_postinstall_script.rendered

  network {
    uuid = openstack_networking_network_v2.osic_network.id
  }
}

# Template for compute devstack installation
data "template_file" "compute_devstack_postinstall_script" {
  template = file("compute-devstack.tpl")
  vars {
    password = "secure"
    controller = openstack_compute_instance_v2.controller_devstack.network.0.fixed_ip_v4
  }
}

resource "openstack_compute_instance_v2" "compute_devstack" {
  count = var.num_computes
  name = "osic-devstack-compute-${count.index + 1}"
  image_name = var.image
  flavor_name = var.flavor
  security_groups = [ openstack_compute_secgroup_v2.devstack_secgroup.name ]
  user_data = data.template_file.compute_devstack_postinstall_script.rendered

  network {
    uuid = openstack_networking_network_v2.osic_network.id
  }
}
