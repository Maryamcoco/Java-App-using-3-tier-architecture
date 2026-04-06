terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
  backend "s3" {
    bucket       = "my-terraform-state-javaapp"
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-northeast-1" # Change this to your desired region                     
  # Configuration options
}


#The S3 Bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-javaapp" # Change this!
  lifecycle {
    prevent_destroy = false
  }
}

# Enable Versioning (Crucial for state)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
