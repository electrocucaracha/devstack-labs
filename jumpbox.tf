resource "template_file" "jumpbox_cloudinit" {
    template = "${file("jumpbox.tpl")}"
}

resource "openstack_compute_secgroup_v2" "jumpbox_secgroup" {
  name = "jumpbox"
  region = "${var.region}"
  description = "Security group for accessing jumpbox from outside"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 8080
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "jumpbox" {
  name = "osic-jumpbox"
  region = "${var.region}"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  security_groups = [ "${openstack_compute_secgroup_v2.jumpbox_secgroup.name}" ]
  floating_ip = "${openstack_compute_floatingip_v2.floatingip.address}"
  user_data = "${template_file.jumpbox_cloudinit.rendered}"

  network {
    uuid = "${openstack_networking_network_v2.private_network.id}"
  }

  provisioner "local-exec" {
    command = "echo \"ssh -o PreferredAuthentications=password -L 6080:192.168.50.$1:6080 -L 8080:192.168.50.$1:80 -t osicer@${openstack_compute_floatingip_v2.floatingip.address} ssh stack@192.168.50.$1\" > ssh-devstack.sh"
  }
}
