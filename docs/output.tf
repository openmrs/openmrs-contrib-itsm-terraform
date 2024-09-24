output "user_access_key_id" {
  value = aws_iam_access_key.bamboo-user-key.id
}

output "user_access_key_secret" {
  value = aws_iam_access_key.bamboo-user-key.secret
  sensitive = true
}

