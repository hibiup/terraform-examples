# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-1"  # Can't refernce to `data.aws_region`
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}


# Local variables
locals {
  instance_type     = "t2.micro"
  environment       = "dev"
  # Local variable can reference to data, or each other within the local range.
  server_name       = "${data.aws_region.current.name}-${local.environment}-app"
  ami_filter_name   = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}


# data "<source_name>" "<instance_name>" {...properties...}
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Get AMI data
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = [local.ami_filter_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# Create EC2 instance
resource "aws_instance" "web_server" {
  ami = data.aws_ami.ubuntu.id
  # Apply local variable
  instance_type = local.instance_type

  tags = {
    Name        = local.server_name
    environment = local.environment
  }
}


# Create EIP for NAT Gateway
resource "aws_eip" "lb" {
  instance = aws_instance.web_server.id
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.lb.id
}

