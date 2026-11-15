output "otel_security_group_id" {
  description = "Security group ID for OTel Collector"
  value       = aws_security_group.otel.id
}

output "otel_asg_name" {
  description = "Auto Scaling Group Name of OTel Collector"
  value       = aws_autoscaling_group.otel.name
}
