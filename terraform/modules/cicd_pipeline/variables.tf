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

variable "github_repository" {
  description = "Full GitHub repository name (e.g. organization/repo)"
  type        = string
}

variable "github_branch" {
  description = "Branch name to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "AWS CodeConnections ARN (formerly CodeStar Connections) to GitHub"
  type        = string
}

variable "asg_name" {
  description = "Name of the target Auto Scaling Group to trigger Instance Refresh"
  type        = string
}

variable "buildspec_path" {
  description = "Path to the buildspec.yml file in repository"
  type        = string
  default     = "buildspec.yml"
}
