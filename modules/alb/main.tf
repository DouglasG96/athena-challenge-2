resource "aws_alb" "main" {
  name               = "${var.project_name}-alb"
  internal           = var.internal_alb
  load_balancer_type = var.load_balancer_type
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  dynamic "access_logs"{
    for_each = var.access_logs
    content {
      bucket = try(lookup(access_logs.value, "bucket"), null)
      prefix = try(lookup(access_logs.value, "prefix"), null)
      enabled = try(lookup(access_logs.value, "enabled"), null)
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.project_name}-alb-sg"
  description = "controls access to the ALB"
  vpc_id = var.vpc_id

  ingress = [{
    protocol = "tcp"
    from_protocol = var.alb_port == null ? 80 : var.alb_port
    to_protocol = var.alb_port == null ? 80 : var.alb_port
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = []
  },
  {
    protocol = "tcp"
    from_protocol = "443"
    to_protocol = "443"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = []
  }]

  egress = {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.project_name}-waf"
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
