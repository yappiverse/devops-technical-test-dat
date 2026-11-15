variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (sit, uat, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "CIDR blocks for private data subnets"
  type        = list(string)
}
