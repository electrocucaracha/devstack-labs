terraform {
  required_providers {
    template = "~> 2.0"
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.1"
    }
  }
}

resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu"
  source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "volume" {
  name           = "volume-${count.index}"
  base_volume_id = libvirt_volume.ubuntu.id
  count          = var.num_devstacks
  size           = 53687091200
}

data "template_file" "devstack_postinstall_script" {
  template = file("${path.module}/../templates/devstack.tpl")
  vars = {
    password = "password"
  }
}

resource "libvirt_cloudinit_disk" "devstack_cloudinit" {
  name      = "devstack.iso"
  user_data = data.template_file.devstack_postinstall_script.rendered
}

resource "libvirt_domain" "devstack" {
  count  = var.num_devstacks
  name   = "osic-devstack-${count.index + 1}"
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.devstack_cloudinit.id

  console {
    type        = "pty"
    target_port = 0
  }

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id = libvirt_network.network_lab.id
    hostname   = "osic-devstack-${count.index + 1}"
  }

  disk {
    volume_id = element(libvirt_volume.volume[*].id, count.index)
  }
}

resource "libvirt_network" "network_lab" {
  name      = "osic-network-lab"
  mode      = "nat"
  addresses = ["10.0.1.0/24"]
}
