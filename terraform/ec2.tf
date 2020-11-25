data "aws_ami" "minecraft" {
  owners           = ["self"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["minecraft-*"]
  }
}

resource "aws_instance" "minecraft" {
  ami           = data.aws_ami.minecraft.id
  instance_type = "t3a.medium"
  key_name      = "minecraft"

  vpc_security_group_ids = [aws_security_group.minecraft.id]

  availability_zone = "us-west-2a"
  subnet_id = aws_subnet.usw2a_public.id

  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_security_group" "minecraft" {
  name        = "minecraft"
  description = "minecraft server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["77.191.142.21/32"]
  }
  
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "ping"
    from_port        = 8
    protocol         = "icmp"
    self             = false
    to_port          = -1
  }

  ingress {
    description = "minecraft game"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "minecraft game UDP"
    from_port   = 25565
    to_port     = 25565
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "minecraft" {
  instance = aws_instance.minecraft.id
  vpc      = true
}

resource "aws_route53_record" "minecraft" {
  zone_id = "ZJO2WR3LOVAR9D"
  name    = "minecraft.pdizz.com"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.minecraft.public_ip]
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = aws_subnet.usw2a_public.availability_zone
  size              = 20

  tags = {
    Name = "minecraft"
  }

  # DONT DELETE THE DATA VOLUME!
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "minecraft" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.minecraft.id
  instance_id = aws_instance.minecraft.id
}
