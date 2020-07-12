terraform {
  required_version = ">= 0.12"
}

data "aws_iam_role" "target_role" {
  name = var.iam_role
}

data "aws_iam_policy_document" "cumulative_s3_policy_document" {
  
  dynamic "statement" {
    iterator = element
    for_each = length(var.list_buckets) > 0 ? var.list_buckets : []
    content {
      sid       = "ListBucket"
      effect    = "Allow"
      actions   = [ "s3:ListBucket" ]
      resources = [ "arn:aws:s3:::${element.value}" ]
    }
  }

  dynamic "statement" {
    for_each = var.get_from_bucket_prefixes != null ? [1] : []
    content {
      sid       = "GetAllObjectsInBucketPrefixes"
      effect    = "Allow"
      actions   = [ "s3:GetObject" ]
      resources = var.get_from_bucket_prefixes != null ? formatlist("arn:aws:s3:::%s/%s", var.get_from_bucket_prefixes.bucket_name, var.get_from_bucket_prefixes.prefixes) : []
    }
  }

  dynamic "statement" {
    for_each = var.get_objects_in_bucket != null ? [1] : []
    content {
      sid       = "GetSpecificObjectsInBucket"
      effect    = "Allow"
      actions   = [ "s3:GetObject" ]
      resources = var.get_objects_in_bucket != null ? formatlist("arn:aws:s3:::%s/%s", var.get_objects_in_bucket.bucket_name, var.get_objects_in_bucket.objects) : []
    }
  }

  dynamic "statement" {
    for_each = var.put_to_bucket_prefixes != null ? [1] : []
    content {
      sid       = "PutObjectsToBucketPrefixes"
      effect    = "Allow"
      actions   = [ "s3:PutObject" ]
      resources = var.put_to_bucket_prefixes != null ? formatlist("arn:aws:s3:::%s/%s", var.put_to_bucket_prefixes.bucket_name, var.put_to_bucket_prefixes.prefixes) : []
    }
  }

  dynamic "statement" {
    iterator = element
    for_each = length(var.kms_ids_for_s3_ro) > 0 ? var.kms_ids_for_s3_ro : []
    content {
      sid       = "KMSForS3Download"
      effect    = "Allow"
      actions   = [ "kms:Decrypt" ]
      resources = formatlist("arn:aws:kms:${var.region}:${var.account_id}:key/%s", element.value)
    }
  }

  dynamic "statement" {
    iterator = element
    for_each = length(var.kms_ids_for_s3_wo) > 0 ? var.kms_ids_for_s3_wo : []
    content {
      sid       = "KMSForS3Upload"
      effect    = "Allow"
      actions   = [ "kms:GenerateDataKey", "kms:Decrypt" ]
      resources = formatlist("arn:aws:kms:${var.region}:${var.account_id}:key/%s", element.value)
    }
  }
  
}

resource "aws_iam_policy" "s3_policy" {
  name = "S3-cumulative-policy"
  policy = data.aws_iam_policy_document.cumulative_s3_policy_document.json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role = data.aws_iam_role.target_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}