variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Service name (backend or frontend)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EC2 Auto Scaling Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.small"
}

variable "min_size" {
  description = "Minimum ASG size"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired ASG capacity"
  type        = number
  default     = 2
}

variable "target_port" {
  description = "Container port to route traffic to (e.g. 8000 for backend, 80 for frontend)"
  type        = number
}

variable "health_check_path" {
  description = "Health check path for ALB Target Group"
  type        = string
  default     = "/health"
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "path_patterns" {
  description = "ALB listener rule path pattern"
  type        = list(string)
}

variable "priority" {
  description = "ALB listener rule priority"
  type        = number
}

variable "user_data_template" {
  description = "Shell script template for cloud-init"
  type        = string
  default     = ""
}
