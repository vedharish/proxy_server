data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "public_security_group" {
  name        = "sg_public_load_balancer"
  description = "Load balancer SG"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH From Everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "Port 80 from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "sg_public_load_balancer"
    app     = "web_server_management"
  }
}

resource "aws_instance" "load_balancer" {
  count                  = local.load_balancer_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = local.key_pair_name
  depends_on             = [ aws_key_pair.provisioner ]
  vpc_security_group_ids = [ aws_security_group.public_security_group.id ]

  tags = {
    Name    = "public_instance_${count.index}"
    Type    = "load_balancer"
    app     = "web_server_management"
  }
}

resource "aws_security_group" "application_security_group" {
  name        = "sg_private_application"
  description = "Application SG"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH From Everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "Port 8484 from everywhere"
    from_port   = 8484
    to_port     = 8484
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "sg_private_application"
    app     = "web_server_management"
  }
}

resource "aws_instance" "applications" {
  count                  = local.application_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet.id
  key_name               = local.key_pair_name
  depends_on             = [ aws_key_pair.provisioner ]
  vpc_security_group_ids = [ aws_security_group.application_security_group.id ]

  tags = {
    Name    = "application_instance_${count.index}"
    Type    = "application"
    app     = "web_server_management"
  }
}
