variable "role_name" {
  default = "developer-role"
}

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

locals {
  account_id   = "000000000000"
  list_buckets = [aws_s3_bucket.b.id]
  get_from_bucket_prefixes = {
    bucket_name = aws_s3_bucket.b.id
    prefixes = [
      "*",
      "component=gfc/*",
      "component=input_telemetry_analytics/subComponent=webflows_v1/date=20200320/*"
    ]
  }
  get_objects_in_bucket = {
    bucket_name = aws_s3_bucket.b.id
    objects = [
      "component=gfc/subComponent=asus/date=20200402/metrics.json"
    ]
  }
  put_to_bucket_prefixes = {
    bucket_name = aws_s3_bucket.b.id
    prefixes = [
      "component=gfc/*",
      "component=input_telemetry_analytics/subComponent=webflows_v1/date=20200322/*"
    ]
  }
  kms_ids_for_s3_rw = [aws_kms_key.key_for_bucket.id]
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole", ]
    principals {
      identifiers = ["arn:aws:iam::${local.account_id}:user/flrnks", ]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "new_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_kms_key" "key_for_bucket" {
  description = "KMS key 1"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-flrnks"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

module "s3_authz" {
  source                   = "../../../tf-module-s3-auth"
  region                   = "eu-central-1"
  iam_role                 = aws_iam_role.new_role.name
  account_id               = local.account_id
  list_buckets             = local.list_buckets
  get_from_bucket_prefixes = local.get_from_bucket_prefixes
  get_objects_in_bucket    = local.get_objects_in_bucket
  put_to_bucket_prefixes   = local.put_to_bucket_prefixes
  kms_ids_for_s3_ro        = local.kms_ids_for_s3_rw
  kms_ids_for_s3_wo        = local.kms_ids_for_s3_rw
}

output "s3_bucket_name" {
  value = aws_s3_bucket.b.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.b.arn
}

output "iam_role_name" {
  value = aws_iam_role.new_role.name
}

output "iam_role_arn" {
  value = aws_iam_role.new_role.arn
}

output "kms_key_id" {
  value = aws_kms_key.key_for_bucket.id
}

output "kms_key_arn" {
  value = aws_kms_key.key_for_bucket.arn
}

output "iam_policy_arn" {
  value = module.s3_authz.iam_policy_arn
}
