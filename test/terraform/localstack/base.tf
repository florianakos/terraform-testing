provider "aws" {
  access_key                  = "mock"
  secret_key                  = "mock"
  region                      = "eu-central-1"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4572"
    kms = "http://localhost:4599"
    iam = "http://localhost:4593"
  }
}

terraform {
  backend "local" {
    path = "./tfstate/terraform.tfstate"
  }
}