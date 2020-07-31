resource "aws_acm_certificate" "certificate" {
  provider          = aws.useast1
  domain_name       = var.dns_address
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = map(
    "Environment", var.env,
    "Service", var.service_name
  )
}
