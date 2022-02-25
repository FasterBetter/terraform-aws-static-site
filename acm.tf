resource "aws_acm_certificate" "static-site" {
  validation_method = "DNS"

  domain_name               = var.domain-name
  subject_alternative_names = var.domain-alternatives

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}
