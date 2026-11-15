output "uploads_bucket_name" {
  description = "S3 Bucket name for user uploads"
  value       = aws_s3_bucket.uploads.bucket
}

output "uploads_bucket_arn" {
  description = "S3 Bucket ARN for user uploads"
  value       = aws_s3_bucket.uploads.arn
}

output "app_secrets_arn" {
  description = "Secrets Manager ARN for application secrets"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "ssm_frontend_api_url_arn" {
  description = "SSM Parameter Store ARN for frontend API URL"
  value       = aws_ssm_parameter.frontend_api_url.arn
}

output "appconfig_application_id" {
  description = "AWS AppConfig Application ID for Feature Flags"
  value       = aws_appconfig_application.main.id
}
