output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.asg.id
}

output "asg_name" {
  description = "Auto Scaling Group Name"
  value       = aws_autoscaling_group.asg.name
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.tg.arn
}

output "iam_role_name" {
  description = "IAM Role Name for the instance"
  value       = aws_iam_role.instance.name
}

output "iam_role_arn" {
  description = "IAM Role ARN for the instance"
  value       = aws_iam_role.instance.arn
}
