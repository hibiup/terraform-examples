#provider "aws" {
#  shared_credentials_files = ["~/.aws/credentials"]
#  profile                  = "default"
#  region                   = var.region
#}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
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
    command = "chmod 600 ${local_file.private_key_file.filename}"
  }
}

# Create ec2
resource "aws_instance" "app_server1" {
  ami           = var.ami
  instance_type = var.size
  associate_public_ip_address = true

  # Add public key from resource
  key_name      = aws_key_pair.my_key_pair.key_name

  security_groups = [
    "default"
  ]

  # provisioner
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello, EC2 Instance!'"
    ]
  }

  # "remote-exec" provisioner requires a connection
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
  value       = [aws_instance.app_server1.public_ip]
}

output "ssh_login_command" {
  description = "SSH access:"
  value       = ["ssh ec2-user@${aws_instance.app_server1.public_ip} -i ${local_file.private_key_file.filename}"]
}

output "web_address" {
  description = "Click the following link to visit the web site"
  value       = ["http://${aws_instance.app_server1.public_ip}"]
}

# Print private key
output "private_key" {
  description = "The private key for ssh access"
  sensitive = true
  value       = tls_private_key.my_key.private_key_pem
}