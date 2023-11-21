# Route 53 hosted zone for your domain
resource "aws_route53_zone" "main" {
  name = "" # Replace with your domain name #TODO create global variables?
}

# A record for the domain apex (root)
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www..com" # Replace with your subdomain #TODO create global variables?
  type    = "A"

  alias {
    name                   = aws_elb.web_elb.dns_name
    zone_id                = aws_elb.web_elb.zone_id
    evaluate_target_health = true
  }
}
