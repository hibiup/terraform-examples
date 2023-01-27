provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-a4c7edb2"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
