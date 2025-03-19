resource "aws_alb" "main" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_wafv2_web_acl" "waf" {
  name        = var.waf_name
  scope       = var.scope
  description = "WAF ACL for ALB"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-acl-metrics"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-Auto-Block-IP"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-metrics"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_waf" {
  resource_arn = aws_alb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
