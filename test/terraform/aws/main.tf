variable "profile" {
  type    = string
  default = "personal-aws"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "iam_role_name" {
  type    = string
  default = "developer-role"
}

variable "s3_bucket_name" {
  type    = string
  default = "flrnks-secure-bucket"
}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  account_arn = data.aws_caller_identity.current.arn
  list_buckets = [
    module.s3_bucket.bucket_id
  ]
  get_object_from_bucket_prefix_list = [{
    bucket_name = module.s3_bucket.bucket_id
    prefixes = [
      "*",
      "component=gfc/*",
      "component=input_telemetry_analytics/subComponent=webflows_v1/date=20200320/*"
    ]
    }, {
    bucket_name = "random-other-bucket-name"
    prefixes    = [
      "component=lol/*"
    ]
  }]
  get_object_from_bucket_list = [{
    bucket_name = module.s3_bucket.bucket_id
    objects = [
      "component=gfc/subComponent=asus/date=20200402/metrics.json"
    ]
  }]
  put_object_to_bucket_prefix_list = [{
    bucket_name = module.s3_bucket.bucket_id
    prefixes = [
      "component=gfc/*",
      "component=input_telemetry_analytics/subComponent=webflows_v1/date=20200322/*"
    ]
  }]
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

data "aws_s3_bucket" "security_logging_bucket" {
  bucket = "flrnks-security-logs"
}

resource "aws_iam_role" "new_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_kms_key" "key_for_bucket" {
  description = "KMS key 1"
}

module "s3_bucket" {
  source                    = "../../../tf-module-s3-bucket"
  region                    = var.region
  profile                   = var.profile
  account_id                = data.aws_caller_identity.current.account_id
  bucket_name               = var.s3_bucket_name
  object_versioning_enabled = true
  logging_bucket            = data.aws_s3_bucket.security_logging_bucket.id
  cidrs_to_write_bucket     = ["0.0.0.0/0"]
  cidrs_to_read_bucket      = ["0.0.0.0/0"]
  cidrs_to_list_bucket      = ["0.0.0.0/0"]
  principals_whitelist      = [aws_iam_role.new_role.arn, local.account_arn]
  default_kms_key_arn       = aws_kms_key.key_for_bucket.arn
}

module "s3_authz" {
  source                             = "../../../tf-module-s3-auth"
  region                             = "eu-central-1"
  iam_role                           = aws_iam_role.new_role.name
  account_id                         = local.account_id
  list_buckets                       = local.list_buckets
  get_object_from_bucket_prefix_list = local.get_object_from_bucket_prefix_list
  get_object_from_bucket_list        = local.get_object_from_bucket_list
  put_object_to_bucket_prefix_list   = local.put_object_to_bucket_prefix_list
  kms_ids_for_readonly_access        = local.kms_ids_for_s3_rw
  kms_ids_for_write_only_access      = local.kms_ids_for_s3_rw
}

output "s3_bucket_name" {
  value = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_bucket.bucket_arn
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
