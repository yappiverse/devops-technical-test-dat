variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "laravel-vue-app"
}

variable "environment" {
  description = "Deployment environment (sit, uat, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.30.1.0/24", "10.30.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "Private app subnet CIDRs"
  type        = list(string)
  default     = ["10.30.11.0/24", "10.30.12.0/24"]
}

variable "data_subnet_cidrs" {
  description = "Private data subnet CIDRs"
  type        = list(string)
  default     = ["10.30.21.0/24", "10.30.22.0/24"]
}

variable "db_instance_class" {
  description = "RDS MySQL instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "db_performance_insights_enabled" {
  description = "Enable Performance Insights for RDS"
  type        = bool
  default     = true
}

variable "db_performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7, 731, or a multiple of 31)"
  type        = number
  default     = 31
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t4g.medium"
}

variable "redis_num_cache_clusters" {
  description = "Number of Redis cache clusters"
  type        = number
  default     = 2
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "c6g.large"
}

variable "frontend_instance_type" {
  description = "EC2 instance type for frontend"
  type        = string
  default     = "t4g.medium"
}

variable "backend_repo" {
  description = "GitHub repo for backend (org/repo)"
  type        = string
  default     = "dat/laravel-backend"
}

variable "frontend_repo" {
  description = "GitHub repo for frontend (org/repo)"
  type        = string
  default     = "dat/vuejs-frontend"
}

variable "github_branch" {
  description = "Target GitHub branch"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "AWS CodeConnections ARN (formerly CodeStar Connections)"
  type        = string
  default     = "arn:aws:codeconnections:ap-southeast-1:123456789012:connection/sample-connection-id"
}
