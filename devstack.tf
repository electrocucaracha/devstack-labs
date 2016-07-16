# Template for devstack installation
resource "template_file" "devstack_postinstall_script" {
  template = "${file("devstack.tpl")}"
  vars {
    password = "secure"
  }
}

resource "openstack_compute_secgroup_v2" "devstack_secgroup" {
  name = "devstack"
  region = "${var.region}"
  description = "Security group for accessing devstack VMs from jumpbox"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    from_group_id = "${openstack_compute_secgroup_v2.jumpbox_secgroup.id}"
  }
}

resource "openstack_compute_instance_v2" "devstack" {
  count = 30
  name = "osic-devstack-${count.index + 1}"
  region = "${var.region}"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  security_groups = [ "${openstack_compute_secgroup_v2.devstack_secgroup.name}" ]
  user_data = "${template_file.devstack_postinstall_script.rendered}"

  network {
    uuid = "${openstack_networking_network_v2.private_network.id}"
  }
}
