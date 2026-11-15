variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Private Subnet IDs for OTel Collector instances"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security Group ID of the application instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for OTel Collector Gateway"
  type        = string
  default     = "t4g.small"
}

variable "otlp_backend_endpoint" {
  description = "Remote OTLP backend endpoint (e.g. Grafana Cloud / Tempo / Mimir)"
  type        = string
  default     = "otlp.grafana.net:4317"
}
