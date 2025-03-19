resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/app-logs"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ECS-HighCPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period            = 60
  statistic         = "Average"
  threshold         = 80
  alarm_description = "Triggers if CPU utilization exceeds 80% for ECS"

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }

  actions_enabled = true
}

resource "aws_guardduty_detector" "guardduty" {
  enable = true
}

resource "aws_securityhub_account" "securityhub" {}

resource "aws_cloudtrail" "main" {
  name           = "cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-logs-${var.aws_region}"
  force_destroy = true
}

resource "aws_vpc_flow_log" "flow_logs" {
  vpc_id          = var.vpc_id
  log_destination = aws_cloudwatch_log_group.ecs_logs.arn
  traffic_type    = "ALL"
}
