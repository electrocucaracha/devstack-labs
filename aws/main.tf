terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = local.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-amd64-minimal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "devstack_cloudinit" {
  template = file("${path.module}/../templates/devstack.tpl")
  vars = {
    password = "password"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  region = "us-west-1"
}

resource "aws_key_pair" "key_pair" {
  public_key = file(var.ssh_public_key_path)
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
  monitoring                  = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.flavor
  vpc_security_group_ids      = [module.devstack_security_group.security_group_id]
  associate_public_ip_address = false
  subnet_id                   = element(module.network_lab.private_subnets, 0)
  user_data_base64            = base64encode(data.template_file.devstack_cloudinit.rendered)

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 50
    },
  ]

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
  monitoring             = true
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.jumpbox_security_group.security_group_id]
  subnet_id              = element(module.network_lab.public_subnets, 0)
  user_data              = file("${path.module}/../scripts/jumpbox.yml")

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 50
    },
  ]

}

module "network_lab" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "osic-network-lab"
  cidr = "10.0.0.0/16"

  azs                = [data.aws_availability_zones.available.names[0]]
  private_subnets    = ["10.0.1.0/24"]
  public_subnets     = ["10.0.101.0/24"]
  enable_nat_gateway = true
  enable_flow_log    = true
}
