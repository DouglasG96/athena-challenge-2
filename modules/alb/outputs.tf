output "alb_dns_name" { value = aws_alb.main.dns_name }
output "alb_arn" { value = aws_alb.main.arn }
output "alb_name" { value = aws_alb.main.name }
output "arn_suffix" { value = aws_alb.main.arn_suffix }
output "alb_security_group_id" { value = try(aws_alb.main.security_groups) }
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_alb_target_group.ecs.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_alb_target_group.ecs.name
}