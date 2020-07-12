data "aws_caller_identity" "current" {}

provider "aws" {
    region  = "eu-central-1"
    profile = "personal-aws"
}

terraform {
  backend "s3" {
    bucket = "terraform-testing-via-go"
    key = "test/s3-authz-test/terraform.tfstate"
    region = "eu-central-1"
    profile = "personal-aws"
  }
  required_version = ">= 0.12"
}