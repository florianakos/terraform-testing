terraform {
  required_version = ">= 0.12"
}

data "aws_iam_role" "target_role" {
  name = var.iam_role
}

data "aws_iam_policy_document" "cumulative_s3_policy_document" {
  
  statement {
    sid       = "ListAllBucketsInAccount"
    effect    = "Allow"
    actions   = [ "s3:GetBucketLocation", "s3:ListAllMyBuckets" ]
    resources = [ "*" ]
  }
  
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
    for_each = length(var.get_object_from_bucket_prefix_list) > 0  ? var.get_object_from_bucket_prefix_list : []
    content {
      sid       = "GetAnyObjectFromBucketPrefixList"
      effect    = "Allow"
      actions   = [ "s3:GetObject" ]
      resources = formatlist("arn:aws:s3:::%s/%s", statement.value.bucket_name , statement.value.prefixes)
    }
  }

  dynamic "statement" {
    for_each = length(var.get_object_from_bucket_list) > 0 ? var.get_object_from_bucket_list : []
    content {
      sid       = "GetSpecificObjectsFromBucket"
      effect    = "Allow"
      actions   = [ "s3:GetObject" ]
      resources = formatlist("arn:aws:s3:::%s/%s", statement.value.bucket_name , statement.value.objects)
    }
  }

  dynamic "statement" {
    for_each = length(var.put_object_to_bucket_prefix_list) > 0 ? var.put_object_to_bucket_prefix_list : []
    content {
      sid       = "PutObjectsToBucketPrefixes"
      effect    = "Allow"
      actions   = [ "s3:PutObject" ]
      resources = formatlist("arn:aws:s3:::%s/%s", statement.value.bucket_name , statement.value.prefixes)
    }
  }

  dynamic "statement" {
    iterator = element
    for_each = length(var.kms_ids_for_readonly_access) > 0 ? var.kms_ids_for_readonly_access : []
    content {
      sid       = "KMSForS3Download"
      effect    = "Allow"
      actions   = [ "kms:Decrypt" ]
      resources = formatlist("arn:aws:kms:${var.region}:${var.account_id}:key/%s", element.value)
    }
  }

  dynamic "statement" {
    iterator = element
    for_each = length(var.kms_ids_for_write_only_access) > 0 ? var.kms_ids_for_write_only_access : []
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