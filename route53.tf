resource "aws_route53_record" "static-site-validation" {
  for_each = {
    for dvo in aws_acm_certificate.static-site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 7200
  type            = each.value.type
  zone_id         = var.zone.zone_id
}

resource "aws_route53_record" "static-site" {
  zone_id = var.zone.zone_id
  name    = var.domain-name
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.static-site.domain_name
    zone_id                = aws_cloudfront_distribution.static-site.hosted_zone_id
  }
}
