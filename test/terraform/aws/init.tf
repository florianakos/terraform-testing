data "aws_caller_identity" "current" {}

provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    key     = "test/s3/terraform.tfstate"
    bucket  = "terraform-testing-via-go"
    region  = "eu-central-1"
    profile = "personal-aws"
  }
  required_version = ">= 0.12"
}
