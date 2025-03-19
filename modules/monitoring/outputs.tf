output "cloudwatch_log_group_name" { value = aws_cloudwatch_log_group.ecs_logs.name }
output "guardduty_enabled" { value = aws_guardduty_detector.guardduty.enable }
output "securityhub_enabled" { value = aws_securityhub_account.securityhub.id }
output "cloudtrail_bucket" { value = aws_s3_bucket.cloudtrail_logs.bucket }
