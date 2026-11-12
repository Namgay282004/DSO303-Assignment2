
# ==========================================================
# DSO303 Assignment 2 - Terraform Outputs
# ==========================================================

output "vpc_id" {
  description = "Assignment 2 VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value = [
    aws_subnet.private_app_a.id,
    aws_subnet.private_app_b.id
  ]
}

output "database_subnet_ids" {
  description = "Isolated database subnet IDs"
  value = [
    aws_subnet.database_a.id,
    aws_subnet.database_b.id
  ]
}

output "alb_dns_name" {
  description = "Public ALB DNS name"
  value       = aws_lb.api.dns_name
}

output "api_autoscaling_group_name" {
  description = "API Auto Scaling Group name"
  value       = aws_autoscaling_group.api.name
}

output "api_target_group_arn" {
  description = "API target group ARN"
  value       = aws_lb_target_group.api.arn
}
