provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}

resource "aws_s3_bucket" "my_s3_bucket" {
    bucket = "my-test-bucket-${random_string.randomness.id}"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  acl    = "private"
}

resource "random_string" "randomness" {
  length = 16
  upper = false
  special = false
}
