output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "List of private app subnet IDs"
  value       = aws_subnet.app[*].id
}

output "data_subnet_ids" {
  description = "List of private data subnet IDs"
  value       = aws_subnet.data[*].id
}

output "alb_id" {
  description = "The ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_listener_arn" {
  description = "The ARN of the primary ALB listener (HTTPS if certificate_arn provided, otherwise HTTP)"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
}

output "alb_http_listener_arn" {
  description = "The ARN of the HTTP ALB listener"
  value       = aws_lb_listener.http.arn
}

output "alb_https_listener_arn" {
  description = "The ARN of the HTTPS ALB listener (empty if not enabled)"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : ""
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID of EC2 App instances (shared/legacy)"
  value       = aws_security_group.app.id
}

output "frontend_security_group_id" {
  description = "Security group ID for Frontend EC2 instances"
  value       = aws_security_group.frontend_app.id
}

output "backend_security_group_id" {
  description = "Security group ID for Backend EC2 instances"
  value       = aws_security_group.backend_app.id
}

