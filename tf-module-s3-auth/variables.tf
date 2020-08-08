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

variable "get_object_from_bucket_prefix_list" {
  default = null
  type = list(object({
    bucket_name     = string
    prefixes        = list(string)
  }))

  description = "BucketName and prefixes for which s3:GetObject permission is granted"
}

variable "put_object_to_bucket_prefix_list" {
  default = null
  type = list(object({
    bucket_name     = string
    prefixes        = list(string)
  }))

  description = "BucketName and list of prefixes for which s3:PutObject permission is granted"
}

variable "get_object_from_bucket_list" {
  default = null
  type = list(object({
    bucket_name     = string
    objects         = list(string)
  }))

  description = "BucketName and list of specific objects for which s3:GetObject is granted"
}

// TODO: add further permissions (DELETE?)

variable "kms_ids_for_readonly_access" {
  default = []
  type = list(string)

  description = "List of KMS key IDs for which READ ONLY access is needed to decrypt and download objects from S3"
}

variable "kms_ids_for_write_only_access" {
  default = []
  type = list(string)

  description = "List of KMS key IDs for which WRITE ONLY access is needed to enrypt and upload objects to S3"
}

