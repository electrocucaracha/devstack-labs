# Template for devstack installation
data "template_file" "devstack_postinstall_script" {
  template = file("devstack.tpl")
  vars {
    password = "password"
  }
}

resource "openstack_compute_secgroup_v2" "devstack_secgroup" {
  name = "osic-lab-devstack"
  description = "Security group for accessing devstack VMs from jumpbox"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    from_group_id = openstack_compute_secgroup_v2.jumpbox_secgroup.id
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    from_group_id = openstack_compute_secgroup_v2.jumpbox_secgroup.id
  }
  rule {
    from_port = 6080
    to_port = 6080
    ip_protocol = "tcp"
    from_group_id = openstack_compute_secgroup_v2.jumpbox_secgroup.id
  }
}

resource "openstack_compute_instance_v2" "devstack" {
  count = var.num_devstacks
  name = "osic-devstack-${count.index + 1}"
  image_name = var.image
  flavor_name = var.flavor
  security_groups = [ "${openstack_compute_secgroup_v2.devstack_secgroup.name}" ]
  user_data = data.template_file.devstack_postinstall_script.rendered

  network {
    uuid = openstack_networking_network_v2.osic_network.id
  }
}
