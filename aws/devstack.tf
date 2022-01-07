data "template_file" "devstack_cloudinit" {
  template = file("${path.module}/../devstack.tftpl")
  vars = {
    password = "password"
  }
}

module "devstack_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "osic-lab-devstack"
  description = "Security group for accessing devstack VMs from jumpbox"
  vpc_id      = module.network_lab.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "devstack_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset([for s in range(var.num_devstacks) : format("%q", s)])

  name                        = "osic-devstack-${each.key}"
  key_name                    = aws_key_pair.key_pair.id
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.xlarge"
  vpc_security_group_ids      = [module.devstack_security_group.security_group_id]
  associate_public_ip_address = false
  subnet_id                   = element(module.network_lab.private_subnets, 0)
  user_data_base64            = base64encode(data.template_file.devstack_cloudinit.rendered)

}
