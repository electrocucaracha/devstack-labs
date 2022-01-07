data "template_file" "jumpbox_cloudinit" {
  template = file("${path.module}/../jumpbox.tftpl")
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
  user_data       = data.template_file.jumpbox_cloudinit.rendered

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
