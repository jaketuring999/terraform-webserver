
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl"
  scope       = "REGIONAL"
  description = "Web ACL for web application"
  default_action {
    allow {}
  }

  rule {
    name     = "BlockXSSRule"
    priority = 1
    action {
      block {}
    }
    statement {
      xss_match_statement {
        field_to_match {
          all_query_arguments {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockXSSRule"
      sampled_requests_enabled   = true
    }
  }
    # Rule to protect against SQL injection
  rule {
    name     = "SQLInjectionRule"
    priority = 2
    action {
      block {}
    }
    statement {
      sqli_match_statement {
        field_to_match {
          all_query_arguments {}  # Inspects all query arguments
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"  # Decodes URL-encoded parts of the request
        }
        text_transformation {
          priority = 1
          type     = "ESCAPE_SEQ_DECODE"  # Processes escape sequences
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled   = true
    }
  }
  # Rate-based rule to protect against DDoS attacks
  rule {
    name     = "RateLimitRule"
    priority = 3
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "web-acl"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webAclVisibility"
    sampled_requests_enabled   = true
  }
  tags = {
    Name = "web-acl"
  }
}


resource "aws_wafv2_web_acl_association" "web_acl_association" {
  resource_arn = aws_elb.web_elb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}
