resource "aws_s3_bucket" "general" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = "true"
  tags          = var.tags

  dynamic "logging" {
    for_each = length(var.logging_bucket) > 0 ? [1] : []
    content {
      target_bucket = var.logging_bucket
      target_prefix = "s3-logs/${var.bucket_name}/"
    }
  }

  versioning {
    enabled    = var.object_versioning_enabled
    mfa_delete = false
  }

  dynamic "server_side_encryption_configuration" {
    for_each = length(var.default_kms_key_arn) > 0 ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = var.default_kms_key_arn
        }
      }
    }
  }
}

resource "aws_s3_bucket_metric" "general_bucket" {
  bucket = aws_s3_bucket.general.id
  name   = "EntireBucket"
}

resource "aws_s3_bucket_policy" "general" {
  bucket = aws_s3_bucket.general.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.general.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = length(var.cidrs_to_write_bucket) > 0 ? "NotIpAddress" : "IpAddress"
      variable = "aws:SourceIp"
      values   = length(var.cidrs_to_write_bucket) > 0 ? var.cidrs_to_write_bucket : ["0.0.0.0/0"]
    }
  }

  statement {
    effect    = "Deny"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.general.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = length(var.cidrs_to_read_bucket) > 0 ? "NotIpAddress" : "IpAddress"
      variable = "aws:SourceIp"
      values   = length(var.cidrs_to_read_bucket) > 0 ? var.cidrs_to_read_bucket : ["0.0.0.0/0"]
    }
  }

  statement {
    effect    = "Deny"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.general.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = length(var.cidrs_to_list_bucket) > 0 ? "NotIpAddress" : "IpAddress"
      variable = "aws:SourceIp"
      values   = length(var.cidrs_to_list_bucket) > 0 ? var.cidrs_to_list_bucket : ["0.0.0.0/0"]
    }
  }

  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.general.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    effect    = "Deny"
    actions   = [ "s3:PutObject", "s3:GetObject", "s3:DeleteObject" ]
    resources = ["${aws_s3_bucket.general.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = concat(var.principals_whitelist, ["arn:aws:iam::${var.account_id}:root"])
    }
  }

//  statement {
//    effect    = "Deny"
//    actions   = [ "s3:ListBucket*" ]
//    resources = [aws_s3_bucket.general.arn]
//    principals {
//      identifiers = ["*"]
//      type        = "AWS"
//    }
//    condition {
//      test     = "ArnNotEquals"
//      variable = "aws:PrincipalArn"
//      values   = concat(var.principals_whitelist,  ["arn:aws:iam::${var.account_id}:root"])
//    }
//  }

  statement {
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.general.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      test     = "Null"
      values   = ["false"]
    }
    condition {
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      test     = "StringNotEquals"
      values   = [var.default_kms_key_arn]

    }
    condition {
      variable = "s3:x-amz-server-side-encryption"
      test     = "Null"
      values   = ["false"]
    }
    condition {
      variable = "s3:x-amz-server-side-encryption"
      test     = "StringNotEquals"
      values   = ["aws:kms"]
    }
  }
}
