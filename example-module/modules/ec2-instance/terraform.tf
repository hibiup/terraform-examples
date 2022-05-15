terraform {
  # Core version
  required_version = ">= 1.1.0"

  # Required provider
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Plugin version
      version = "~> 4.12.0"
    }
  }
}
