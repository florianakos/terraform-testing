output "bucket_arn" {
  value = aws_s3_bucket.general.arn
}

output "bucket_id" {
  value = aws_s3_bucket.general.id
}

output "bucket_name" {
  value = var.bucket_name
}
