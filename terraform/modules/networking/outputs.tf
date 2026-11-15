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
  description = "The ARN of the default HTTP ALB listener"
  value       = aws_lb_listener.http.arn
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID of EC2 App instances"
  value       = aws_security_group.app.id
}
