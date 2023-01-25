# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-1"  # Can't refernce to `data.aws_region`
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}


# data "<source_name>" "<instance_name>" {...properties...}
#
# Be available after the process starting, so it can not be referenced form `provider`.
#
# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}

# Retrieve region, generate an object named "current"
data "aws_region" "current" {}

# Get AMI data
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}


# Create EC2
resource "aws_instance" "web_server" {
  # Apply AMI data
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}


# Create EIP
resource "aws_eip" "lb" {
  instance = aws_instance.web_server.id
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.lb.id
}

