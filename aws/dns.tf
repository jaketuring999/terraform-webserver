# Route 53 hosted zone for your domain
resource "aws_route53_zone" "main" {
  name = var.domain
}

# A record for the domain apex (root)
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${var.sub_domain}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_elb.web_elb.dns_name
    zone_id                = aws_elb.web_elb.zone_id
    evaluate_target_health = true
  }
}
