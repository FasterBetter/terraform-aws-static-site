# tfsec:ignore:aws-cloudfront-enable-waf
resource "aws_cloudfront_distribution" "static-site" {
  # N.B. A WAF seems like an unnecessary choice for a distribution whose origin is S3.
  origin {
    domain_name = aws_s3_bucket.static-site.website_endpoint
    origin_id   = local.static-site-origin-id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed through Terraform.  Do not treat configure-s3-website gem as authoritative!"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = true
  #   bucket          = var.logging-bucket.bucket_domain_name
  #   prefix          = join("/", [var.name, "cloudfront"])
  # }

  aliases = concat([var.domain-name], var.domain-alternatives)

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.static-site-origin-id
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.lambdas
      content {
        event_type   = lambda_function_association.key
        lambda_arn   = lambda_function_association.value
        include_body = false
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min-ttl
    default_ttl            = var.default-ttl
    max_ttl                = var.max-ttl
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 300
  }

  dynamic "custom_error_response" {
    for_each = [400, 403, 405, 414, 416, 500, 501, 502, 503, 504]
    content {
      error_code            = custom_error_response.value
      response_page_path    = "/error.html"
      response_code         = custom_error_response.value
      error_caching_min_ttl = 300
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.static-site.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }
}
