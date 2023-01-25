# Configure the AWS Provider
provider "aws" {
  region                   = var.aws_region[var.region_alias]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}


#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}   # Get from `provider.aws.region`

# Get AMI data
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = [var.ami_filter_name]
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
  # Apply input variable
  instance_type = var.instance_type[var.plan]

  tags = {
    Name = "${data.aws_region.current.name}-${var.environment}-app"
    environment = var.environment
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