provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-a4c7edb2"
  instance_type = "t2.micro"

  tags = {
    Name = "Ubuntu EC2 Server"
  }
}

output "web_server_ip" {
  description = "Public IP Address of Web Server on EC2"
  value = aws_instance.web_server.public_ip
  # Is it sensitive?
  sensitive = true
}
