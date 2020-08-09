output "iam_role_name" {
  value = var.target_role_name
}

output "iam_policy_name" {
  value = aws_iam_policy.s3_policy.name
}

output "iam_policy_arn" {
  value = aws_iam_policy.s3_policy.arn
}

output "policy_json" {
  value = data.aws_iam_policy_document.cumulative_s3_policy_document.json
}