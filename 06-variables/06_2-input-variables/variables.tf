#variable “<VARIABLE_NAME>” {
## Block body
#  type = <VARIABLE_TYPE>
#  description = <DESCRIPTION>
#  default = <EXPRESSION>
#  sensitive = <BOOLEAN>
#  validation = <RULES>
#}


# No defailt value. terraform will prompt for input.
variable "aws_region" {
  description = "Available region"
  type      = map
  default = {
    "east"  = "us-east-1"
    "west"  = "ws-west-1"
  }
}

variable "region_alias" {
  type        = string
  description = "Region used to deploy workloads? (east or west)"
  validation {
    condition     = can(regex("^(east|west)$", var.region_alias))
    error_message = "Invalid region"
  }
}

# Auto-filled or override by terraform.tfvars
variable "environment" {
  description  = "Environment"
  type         = string
  default      = "prod"
  validation {
    condition     = can(regex("^(dev|qa|prod)$", var.environment))
    error_message = "Invalid environment"
  }
}

# A map, choose by `var.instance_type[var.plan]`
variable "instance_type" {
  description  = "EC2 Instance type"
  type = list
  default = [ "t2.micro", "t2.small", "t2.large" ]
}

variable plan {
  description  = "What's your plan? (0: micro, 1: small or 2: large):"
  type = number
  # Input validater ...
}


# Just default value. No prompt, but can be override by command line:
#   `terraform apply -var ami_filter_name="..."`
variable "ami_filter_name" {
  description  = "AMI name search filter condition"
  type         = string
  default      = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}
