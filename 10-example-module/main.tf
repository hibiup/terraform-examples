#module “<MODULE_NAME>” {
## Block body
#  source = <MODULE_SOURCE>
#  <INPUT_NAME> = <DESCRIPTION> #Inputs
#  <INPUT_NAME> = <DESCRIPTION> #Inputs
#}

module "my_ec2_instance" {
  source = "./modules/ec2-instance"
  ami    = "ami-0fab23c65778d8fe0"
  region = "us-east-1"
}

output "ssh_login_command" {
  description = "SSH access:"
  value       = module.my_ec2_instance.ssh_login_command
}

output "web_address" {
  description = "Click the following link to visit the web site"
  value       = module.my_ec2_instance.web_address
}

# Print private key
output "private_key" {
  description = "The private key for ssh access"
  sensitive = true
  value       = module.my_ec2_instance.private_key
}