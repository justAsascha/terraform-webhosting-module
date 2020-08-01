resource "aws_route53_zone" "primary" {
  name = var.hosted_zone
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
