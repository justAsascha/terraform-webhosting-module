##############
# CloudFront #
##############
locals {
  static_s3_origin_id = "s3-origin-id-${var.static_content_bucket_name}"
  webapp_s3_origin_id = "s3-origin-id-${var.webapp_bucket_name}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Static Content - ${var.env}"
}

resource "aws_cloudfront_distribution" "hosting" {
  # single page application
  origin {
    domain_name = module.webapp_s3.this_s3_bucket_bucket_regional_domain_name
    origin_id   = local.webapp_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  # static files
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
  price_class         = var.cloudfront_price_class

  web_acl_id = aws_waf_web_acl.waf_acl.id

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.webapp_s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Authorization",
      ]
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.lambda_edge.qualified_arn
      include_body = true
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/statics/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.static_s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}
