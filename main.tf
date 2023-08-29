module "openstack-provider" {
  source = ".//openstack"
}

module "aws-provider" {
  source = ".//aws"
}

module "libvirt-provider" {
  source = ".//libvirt"
}
