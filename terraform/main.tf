provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "pdizz_tfstate" {
  bucket = "pdizz-tfstate"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "pdizz_tflocks" {
  name         = "pdizz-tflocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "pdizz-tfstate"
    key            = "minecraft/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "pdizz-tflocks"
    encrypt        = true
  }
}
