resource "aws_alb" "main" {
  name               = "${var.project_name}-alb"
  internal           = var.internal_alb
  load_balancer_type = var.load_balancer_type
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb.id]

  # dynamic "access_logs" {
  #   for_each = var.access_logs
  #   content {
  #     bucket  = try(lookup(access_logs.value, "bucket"), null)
  #     prefix  = try(lookup(access_logs.value, "prefix"), null)
  #     enabled = try(lookup(access_logs.value, "enabled"), null)
  #   }
  # }
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port   = var.alb_port == null ? 80 : var.alb_port
    to_port     = var.alb_port == null ? 80 : var.alb_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }
  ingress {
    protocol        = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project_name}-alb-sg"
  } 
}

# Target Group for ECS Service
resource "aws_alb_target_group" "ecs" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/docs"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
  deregistration_delay = "30"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
  depends_on = [ aws_alb.main ]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = var.alb_port == null ? 80 : var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs.arn
  }
}

#WAF

resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.project_name}-waf"
  scope       = var.scope
  description = "WAF ACL for ALB"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf-acl-metrics"
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
      metric_name                = "${var.project_name}-rate-limit-metrics"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_waf" {
  resource_arn = aws_alb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
