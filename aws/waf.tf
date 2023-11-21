resource "aws_wafv2_ip_set" "allowlist_ip_set" {
  name               = "allowlist-ip-set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = [
    "", # TODO allow a cidr block of IPS?
  ]
}

resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl"
  scope       = "REGIONAL"
  description = "Web ACL for web application"
  default_action {
    allow {}
  }

  rule {
    name     = "IPAllowListRule"
    priority = 1
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowlist_ip_set.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPAllowListRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BlockXSSRule"
    priority = 2
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
          type     = "NONE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockXSSRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl"
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
