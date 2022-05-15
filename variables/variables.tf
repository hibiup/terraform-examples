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
  validation {
    condition     = can(regex("^us-", var.aws_region))
    error_message = "Invalid region"
  }
}
