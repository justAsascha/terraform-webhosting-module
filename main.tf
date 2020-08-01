terraform {
  required_version = ">= 0.12.28"
}
# used to fetch ssl certificates 
# (must be defined in us-east-1)
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

provider "aws" {
  version = "~> 2.35"
  region  = "eu-west-1"
}

#################
# TEST ACM CERT #
#################
resource "aws_acm_certificate" "certificate" {
  provider          = aws.useast1
  domain_name       = "test.justagency.de"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  zone_id = "Z0800165I302K1PHD4DT"
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

#################
# DEMO SHOWCASE #
#################
module "hosting" {
  source       = "./modules/hosting"
  region       = "eu-west-1"

  static_content_bucket_name = "epilot-statics-demo"
  webapp_bucket_name         = "epilot-webapp-demo"

  hosted_zone            = "justagency.de."
  dns_address            = "test.justagency.de"
  cloudfront_price_class = "PriceClass_100"
  acm_certificate_arn    = aws_acm_certificate.certificate.arn

  basic_auth_username = "demo"
  basic_auth_password = "secret"

  allowlist_cdirs = [
    { value = "5.146.105.103/32", type = "IPV4" },
  ]
}

output "cloudfront_id" {
  value = module.hosting.cloudfront_id
}

output "lambda_edge_arn" {
  value = module.hosting.lambda_edge_arn
}

output "webapp_s3_arn" {
  value = module.hosting.webapp_s3_arn
}

output "static_s3_arn" {
  value = module.hosting.static_s3_arn
}

output "hosted_zone_id" {
  value = module.hosting.hosted_zone_id
}
