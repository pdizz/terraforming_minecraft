resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
}

resource "aws_subnet" "usw2a_public" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-west-2a"
  cidr_block = var.sub_cidr
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  # so tf doesnt try to delete vpc before this
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "usw2a_public" {
  subnet_id      = aws_subnet.usw2a_public.id
  route_table_id = aws_route_table.public.id
}
