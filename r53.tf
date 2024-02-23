#uncomment this if you already have a hosted zone you want to use
# import {
#   to = aws_route53_zone.primary
#   id = ""
# }

# Build the hosted zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

# main record for pds functionality
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# prevents "invalid handle" issues
resource "aws_route53_record" "handles" {
    zone_id = aws_route53_zone.primary.zone_id
    name = "*.${var.domain_name}"
    type = "CNAME"
    records = [ var.domain_name ]
    ttl = 300
}