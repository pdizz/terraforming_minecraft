resource "aws_instance" "minecraft" {
  ami           = "ami-0bc06212a56393ee1" # centos 7 minimal
  instance_type = "t3a.medium"
  key_name      = "minecraft"

  vpc_security_group_ids = [aws_security_group.minecraft.id]

  availability_zone = "us-west-2a"
  subnet_id = aws_subnet.usw2a_public.id

  root_block_device {
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    yum -y install java
    useradd --shell /bin/false --home-dir /opt/minecraft minecraft
    yum -y install wget
    wget -qO /opt/minecraft/server.jar https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar
    echo "eula=true" > /opt/minecraft/eula.txt
    cd /opt/minecraft && nohup /usr/bin/java -Xms2048M -Xmx2048M -XX:+UseG1GC -jar server.jar nogui &
    EOF
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
