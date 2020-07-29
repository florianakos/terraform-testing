variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "account_id" {
  type = string
}

variable "bucket_name" {
  description = "Name of the bucket to create"
  type        = string
}

variable "cidrs_to_write_bucket" {
  type        = list(string)
  default     = []
  description = "Whitelist source CIDRs that can UPLOAD to bucket"
}

variable "cidrs_to_read_bucket" {
  type        = list(string)
  default     = []
  description = "Whitelist source CIDRs that can DOWNLOAD from bucket"
}

variable "cidrs_to_list_bucket" {
  type        = list(string)
  default     = []
  description = "Whitelist source CIDRs that can LIST bucket contents"
}

variable "default_kms_key_arn" {
  type        = string
  description = "Enforced KSM Encryption key on the Bucket"
}

variable "tags" {
  type        = map(string)
  description = "tags added to all AWS resources"
  default = {
    Author = "flrnks"
    Module = "tf-module-s3-bucket"
  }
}

variable "object_versioning_enabled" {
  type        = bool
  description = "Bucket versioning enabled"
}

variable "logging_bucket" {
  type        = string
  description = "Name of the bucket where logs will be stored"
}

variable "principals_whitelist" {
  description = "IAM Roles/Users that are not listed here are denied explicitly"
  type        = list(string)
}



