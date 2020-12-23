provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "pdizz-tfstate"
    key            = "minecraft/prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "pdizz-tflocks"
    encrypt        = true
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "minecraft"
  cidr = "172.16.0.0/24"

  azs            = ["us-west-2a"]
  public_subnets = ["172.16.0.0/26"]

  create_igw = true
}

data "aws_ami" "minecraft" {
  owners           = ["self"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["minecraft-*"]
  }
}

module "ec2" {
  source = "modules/ec2"

  ami_id            = data.aws_ami.minecraft.id
  instance_type     = "m5a.large"
  availability_zone = "us-west-2a"
  subnet_id         = module.vpc.public_subnets[0]
  vpc_id            = module.vpc.vpc_id
  ssh_cidr_blocks   = ["77.191.142.21/32"]
  data_volume_id    = aws_ebs_volume.minecraft.id
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = "us-west-2a"
  size              = 20

  # DONT DELETE THE DATA VOLUME!
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "minecraft" {
  instance = module.ec2.instance.id
  vpc      = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "minecraft" {
    zone_id = "ZJO2WR3LOVAR9D"
    name    = "minecraft.pdizz.com"
    type    = "A"
    ttl     = "300"
    records = [aws_eip.minecraft.public_ip]
}
