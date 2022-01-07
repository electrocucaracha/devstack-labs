data "template_file" "jumpbox_cloudinit" {
  template = file("${path.module}/../jumpbox.tftpl")
}

module "jumpbox_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "osic-lab-jumpbox"
  description = "Security group for accessing jumpbox from outside"
  vpc_id      = module.network_lab.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "jumpbox_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "osic-jumpbox"
  key_name               = aws_key_pair.key_pair.id
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.jumpbox_security_group.security_group_id]
  subnet_id              = element(module.network_lab.public_subnets, 0)
  user_data_base64       = base64encode(data.template_file.jumpbox_cloudinit.rendered)

}
