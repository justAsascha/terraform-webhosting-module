resource "aws_route53_zone" "primary" {
  name = var.hosted_zone
}

resource "aws_route53_record" "cert_validation" {
  zone_id = aws_route53_zone.primary.id
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]

  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_route53_record" "hosting" {
  zone_id = aws_route53_zone.primary.id
  name    = var.dns_address
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.hosting.domain_name
    zone_id                = aws_cloudfront_distribution.hosting.hosted_zone_id
    evaluate_target_health = false
  }
}
