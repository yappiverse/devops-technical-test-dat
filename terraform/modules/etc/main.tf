resource "random_id" "s3_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "uploads" {
  bucket        = "${var.project_name}-${var.environment}-uploads-${random_id.s3_suffix.hex}"
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-uploads"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "/${var.environment}/${var.project_name}/app-secrets"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DB_HOST          = var.db_host
    DB_PASSWORD      = var.db_password
    REDIS_HOST       = var.redis_host
    REDIS_AUTH_TOKEN = var.redis_auth_token
  })
}

resource "aws_ssm_parameter" "frontend_api_url" {
  name        = "/${var.environment}/${var.project_name}/frontend/api_base_url"
  description = "Public API Base URL used by Vue.js SPA entrypoint"
  type        = "String"
  value       = "https://api.example.com"

  tags = {
    Name        = "${var.project_name}-${var.environment}-frontend-api-url"
    Environment = var.environment
  }
}

resource "aws_appconfig_application" "main" {
  name        = "${var.project_name}-${var.environment}-appconfig"
  description = "Feature Flags and Emergency Kill Switch configuration"

  tags = {
    Name        = "${var.project_name}-${var.environment}-appconfig"
    Environment = var.environment
  }
}

resource "aws_appconfig_environment" "main" {
  application_id = aws_appconfig_application.main.id
  name           = var.environment
  description    = "${var.environment} environment for feature flags"
}

resource "aws_appconfig_configuration_profile" "flags" {
  application_id = aws_appconfig_application.main.id
  name           = "feature-flags"
  location_uri   = "hosted"
  type           = "AWS.Freeform"
}

resource "aws_appconfig_hosted_configuration_version" "initial" {
  application_id           = aws_appconfig_application.main.id
  configuration_profile_id = aws_appconfig_configuration_profile.flags.configuration_profile_id
  content_type             = "application/json"

  content = jsonencode({
    kill_switches = {
      disable_export_reports = false
      maintenance_mode       = false
    }
    feature_flags = {
      enable_new_dashboard = true
    }
  })
}
