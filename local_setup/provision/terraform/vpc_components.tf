resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    app     = "web_server_management"
    Name    = "vpc_web_server_management"
  }
}

resource "aws_internet_gateway" "main_vpc_gateway" {
  vpc_id       = aws_vpc.main_vpc.id

  tags = {
    Name       = "internet-gateway-vpc-main"
    managed-by = "terraform"
    app        = "web_server_management"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = true

  tags = {
    Name                                   = "public_subnet"
    app                                    = "web_server_management"
    managed-by                             = "terraform"
  }
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id                  = aws_vpc.main_vpc.id

  tags = {
    Name       = "route_table_vpc_${replace(local.region, "-", "_")}_public_subnet"
    app        = "web_server_management"
    managed-by = "terraform"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_associations" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

resource "aws_route" "vpc_default_gateway" {
  route_table_id         = aws_vpc.main_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_vpc_gateway.id
}

resource "aws_route" "subnet_internet_gateway" {
  route_table_id         = aws_route_table.public_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_vpc_gateway.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.64/26"
  map_public_ip_on_launch = false

  tags = {
    Name                                   = "private_subnet"
    app                                    = "web_server_management"
    managed-by                             = "terraform"
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id                  = aws_vpc.main_vpc.id

  tags = {
    Name       = "route_table_vpc_${replace(local.region, "-", "_")}_private_subnet"
    app        = "web_server_management"
    managed-by = "terraform"
  }
}

resource "aws_route_table_association" "private_subnet_route_table_associations" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

resource "aws_key_pair" "provisioner" {
  key_name      = local.key_pair_name
  public_key    = file("${path.module}/provision_public_key")

  tags = {
    Name    = local.key_pair_name
    app     = "web_server_management"
  }
}
