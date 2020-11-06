resource "aws_vpc" "main" {
  cidr_block       = "172.16.0.0/24"
  instance_tenancy = "default"
}

resource "aws_subnet" "usw2a_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.16.0.0/26"
  map_public_ip_on_launch = true
    
  tags = {
    Name = "minecraft"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "minecraft"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "minecraft"
  }
}

resource "aws_route_table_association" "usw2a_public" {
  subnet_id      = aws_subnet.usw2a_public.id
  route_table_id = aws_route_table.public.id
}
