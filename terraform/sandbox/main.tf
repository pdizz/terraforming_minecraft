provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "pdizz-tfstate"
    key            = "minecraft/sandbox/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "pdizz-tflocks"
    encrypt        = true
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "minecraft-sb"
  cidr = "172.16.10.0/24"

  azs            = ["us-west-2a"]
  public_subnets = ["172.16.10.0/26"]

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
  source = "../modules/ec2"

  ami_id            = data.aws_ami.minecraft.id
  instance_type     = "t3a.medium"
  availability_zone = "us-west-2a"
  subnet_id         = module.vpc.public_subnets[0]
  vpc_id            = module.vpc.vpc_id
  ssh_cidr_blocks   = ["77.191.142.21/32"]
  data_volume_id    = aws_ebs_volume.minecraft.id
}

# snapshot prod volume to build sandbox
data "terraform_remote_state" "prod" {
  backend = "s3"
  config = {
    bucket = "pdizz-tfstate"
    key    = "minecraft/prod/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_ebs_snapshot" "minecraft_prod" {
  volume_id   = data.terraform_remote_state.prod.outputs.volume.id
  description = "prod snapshot for sandbox env data"

  tags = {
    Name = "minecraft-sb"
  }
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = "us-west-2a"
  size              = 20

  snapshot_id = aws_ebs_snapshot.minecraft_prod.id

  tags = {
    Name = "minecraft-sb"
  }
}

# resource "aws_eip" "minecraft" {
#   instance = module.ec2.instance.id
#   vpc      = true
# }

resource "aws_route53_record" "minecraft" {
    zone_id = "Z3ARJOLOV2WR9D"
    name    = "minecraft-sb.pdizz.com"
    type    = "A"
    ttl     = "300"
    records = [module.ec2.instance.public_ip]
}
