resource "aws_instance" "minecraft" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = "minecraft"

  vpc_security_group_ids = [aws_security_group.minecraft.id]

  availability_zone = var.availability_zone
  subnet_id         = var.subnet_id

  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_security_group" "minecraft" {
  name        = "minecraft"
  description = "minecraft server"
  vpc_id      = var.vpc_id
  tags        = var.resource_tags

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
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

resource "aws_volume_attachment" "minecraft" {
  device_name = "/dev/sdf"
  volume_id   = var.data_volume_id
  instance_id = aws_instance.minecraft.id
}
