variable "region" {
  default = "eu-central-1"
  type = string
}

variable "account_id" {
  default = null
  type = string
}

variable "iam_role" {
  type = string
  description = "Name of the IAM Role to which the S3 policies will be attached"
}

variable "list_buckets" {
  default = []
  type = list(string)

  description = "List of Buckets for which the role needs s3:ListBucket permissions"
}

variable "get_from_bucket_prefixes" {
  default = null
  type = object({
    bucket_name     = string
    prefixes        = list(string)
  })

  description = "Bucketname and prefixes for which s3:GetObject permission is needed"
}

variable "put_to_bucket_prefixes" {
  default = null
  type = object({
    bucket_name     = string
    prefixes        = list(string)
  })

  description = "Bucketname and prefixes for which s3:PutObject permission is needed"
}

variable "get_objects_in_bucket" {
  default = null
  type = object({
    bucket_name     = string
    objects         = list(string)
  })

  description = "Bucket name and list of objects that should be possble to GET"
}

variable "kms_ids_for_s3_ro" {
  default = []
  type = list(string)

  description = "List of KMS key IDs for which READ ONLY access is needed to decrypt and download from S3"
}

variable "kms_ids_for_s3_wo" {
  default = []
  type = list(string)

  description = "List of KMS key IDs for which WRITE ONLY access is needed to encrypt and upload from S3"
}

