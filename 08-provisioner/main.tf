provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}

# Define key algorithm
resource "tls_private_key" "my_key" {
  algorithm            = "RSA"
  rsa_bits             = 4096
}

# generate key pare
resource "aws_key_pair" "my_key_pair" {
  key_name             = "deployer-key"
  public_key           = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  content              = tls_private_key.my_key.private_key_pem
  filename             = "private.pem"

  # Change file permission
  provisioner "local-exec" {
    # Single command
    command            = "chmod 600 ${local_file.private_key_file.filename}"
  }
}

# Create ec2
resource "aws_instance" "web_server" {
  ami                  = "ami-00874d747dde814fa"
  instance_type        = "t1.micro"

  # Add public key from resource
  key_name             = aws_key_pair.my_key_pair.key_name

  vpc_security_group_ids = [
    aws_security_group.service_sg.id,
    aws_security_group.management_sg.id
  ]

  # init VM to install httpd
  user_data = <<EOF
        #! /bin/bash
        sudo apt-get update -y
        sudo apt-get install -y apache2
        echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
        EOF
  
  # remote provisioner
  provisioner "remote-exec" {
    # Multiple commands
    inline = [
      "echo 'Hello, EC2 Instance'"
    ]
  }

  # We need a connection for provisioner remote login
  connection {
    user = "ubuntu"
    private_key        = tls_private_key.my_key.private_key_pem
    host               = self.public_ip
  }

  tags = {
    Name               = "HelloWorld"
  }
}

# Volume
resource "aws_ebs_volume" "data_volume" {
    availability_zone  = aws_instance.web_server.availability_zone
    size               = 8
}

resource "aws_volume_attachment" "ebs_att" {
     device_name       = "/dev/sdh"
     volume_id         = aws_ebs_volume.data_volume.id
     instance_id       = aws_instance.web_server.id
}

# Bundle with EIP
resource "aws_eip" "lb" {
  instance             = aws_instance.web_server.id
  vpc                  = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id          = aws_instance.web_server.id
  allocation_id        = aws_eip.lb.id
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "service_sg" {
  name                 = "allow_http_service"
  description          = "Allow HTTP/HTTPS inbound traffic"

  ingress {
    description        = "HTTPS from VPC"
    from_port          = 443
    to_port            = 443
    protocol           = "tcp"
    # Open to public
    cidr_blocks        = ["0.0.0.0/16"]
    # If allows form VPC only
    #cidr_blocks        = [data.aws_vpc.default.cidr_block]
    #ipv6_cidr_blocks   = [data.aws_vpc.default.ipv6_cidr_block]
  }

  ingress {
    description        = "HTTP from VPC"
    from_port          = 80
    to_port            = 80
    protocol           = "tcp"
    # Open to public
    cidr_blocks        = ["0.0.0.0/16"]
    # If allows form VPC only
    #cidr_blocks        = [data.aws_vpc.default.cidr_block]
    #ipv6_cidr_blocks   = [data.aws_vpc.default.ipv6_cidr_block]
  }

  egress {
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    cidr_blocks        = ["0.0.0.0/0"]
    ipv6_cidr_blocks   = ["::/0"]
  }

  tags = {
    Name               = "allow_http_service"
  }
}

resource "aws_security_group" "management_sg" {
  name                 = "allow_ssh"
  description          = "Allow SSG inbound traffic"

  ingress {
    description        = "SSH from VPC"
    from_port          = 22
    to_port            = 22
    protocol           = "tcp"
    # Source
    cidr_blocks        = ["0.0.0.0/0"]
  }

  egress {
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    cidr_blocks        = ["0.0.0.0/0"]
    ipv6_cidr_blocks   = ["::/0"]
  }

  tags = {
    Name               = "allow_ssh"
  }
}

# Print out instance ip
output "instance_ip" {
  description          = "The public ip for ssh access"
  value                = aws_eip.lb.public_ip
}

output "ssh_login_command" {
  description          = "SSH access:"
  value                = "ssh ubuntu@${aws_eip.lb.public_ip} -i ${local_file.private_key_file.filename}"
}

output "web_address" {
  description          = "Click the following link to visit the web site"
  value                = "http://${aws_eip.lb.public_ip}"
}

# Print private key
output "private_key" {
  description          = "The private key for ssh access"
  sensitive            = true
  value                = tls_private_key.my_key.private_key_pem
}
