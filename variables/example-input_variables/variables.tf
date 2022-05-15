#variable “<VARIABLE_NAME>” {
## Block body
#  type = <VARIABLE_TYPE>
#  description = <DESCRIPTION>
#  default = <EXPRESSION>
#  sensitive = <BOOLEAN>
#  validation = <RULES>
#}

variable "aws_region" {
  type        = string
  description = "region used to deploy workloads"
  default     = "us-east-1"
  #validation {
  #  condition     = can(regex("^us-", var.aws_region))
  #  error_message = "Invalid region"
  #}
}

variable "vpc_name" {
  type    = string
  default = "demo_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
    "private_subnet_3" = 3
  }
}

variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
    "public_subnet_3" = 3
  }
}

variable "variables_sub_az" {
  description = "Availablity zone"
  type = string
}