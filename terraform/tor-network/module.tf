terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
}

data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-10-amd64-20200803-347"]
  }

  owners = ["136693071363"] # Debian
}

data "aws_availability_zones" "default" {
  all_availability_zones = true
}

resource "aws_security_group" "default" {
  name        = "Tor Security Group"
  description = "The SG for Tor"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    description = "Tor instance 1"
    from_port   = 9000
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Tor instance 2"
    from_port   = 9100
    to_port     = 9101
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.207.254.118/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_vpc" "default" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_instance" "default" {
  count                       = 1
  # If you want to use many servers per AZ use this count assignment
  #count                       = length(data.aws_availability_zones.default.names) * var.servers_per_az
  instance_type               = var.instance_type
  ami                         = data.aws_ami.default.id
  key_name                    = "tor"
  monitoring                  = true # CloudWatch Monitoring
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  tags = {
    Name = "tor-server"
  }
}
