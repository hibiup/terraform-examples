provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}

# Define key algorithm
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# generate key pare
resource "aws_key_pair" "my_key_pair" {
  key_name   = "deployer-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  content = tls_private_key.my_key.private_key_pem
  filename = "private.pem"

  # Change file permission
  provisioner "local-exec" {
    # Single command
    command = "chmod 600 ${local_file.private_key_file.filename}"
  }
}

# Create ec2
resource "aws_instance" "app_server" {
  ami           = "ami-0fab23c65778d8fe0"
  instance_type = "t1.micro"
  associate_public_ip_address = true

  # Add public key from resource
  key_name      = aws_key_pair.my_key_pair.key_name

  security_groups = [
    "default"
  ]

  # init VM to install httpd
  user_data = <<EOF
        #! /bin/bash
        sudo yum update -y
        sudo yum install -y httpd
        sudo service httpd start
        sudo chkconfig httpd on
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
    user = "ec2-user"
    private_key = tls_private_key.my_key.private_key_pem
    host = self.public_ip
  }

  tags = {
    Name = "HelloWorld"
  }
}

# Print out instance ip
output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.app_server.public_ip
}

output "ssh_login_command" {
  description = "SSH access:"
  value       = "ssh ec2-user@${aws_instance.app_server.public_ip} -i ${local_file.private_key_file.filename}"
}

output "web_address" {
  description = "Click the following link to visit the web site"
  value       = "http://${aws_instance.app_server.public_ip}"
}

# Print private key
output "private_key" {
  description = "The private key for ssh access"
  sensitive = true
  value       = tls_private_key.my_key.private_key_pem
}
