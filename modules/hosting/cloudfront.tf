##############
# CloudFront #
##############
locals {
  static_s3_origin_id = "static-s3-${var.env}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Static Content - ${var.env}"
}

resource "aws_cloudfront_distribution" "hosting" {
  origin {
    domain_name = module.static_content_s3.this_s3_bucket_bucket_regional_domain_name
    origin_id   = local.static_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases = [var.dns_address]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  #   web_acl_id = aws_waf_web_acl.waf_acl.id

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.static_s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 86400
    default_ttl = 86400
    max_ttl     = 86400

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Environment = var.env
    Service     = var.service_name
  }

  depends_on = [aws_acm_certificate.certificate]
}
