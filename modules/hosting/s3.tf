##############################
# S3 Bucket for static files #
##############################
# Allow read access only from given CloudFront distribution
data "aws_iam_policy_document" "static_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.static_content_s3.this_s3_bucket_arn}/*"]

    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [module.static_content_s3.this_s3_bucket_arn]

    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id]
    }
  }
}

module "static_content_s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = var.static_content_bucket_name
  acl           = "private"
  force_destroy = true
  attach_policy = true
  policy        = data.aws_iam_policy_document.static_bucket_policy.json

  versioning = {
    enabled = false
  }
}

#################################
# S3 Bucket for single page app #
#################################
# Allow read access only from given CloudFront distribution
data "aws_iam_policy_document" "webapp_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.webapp_s3.this_s3_bucket_arn}/*"]

    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [module.webapp_s3.this_s3_bucket_arn]

    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id]
    }
  }
}

module "webapp_s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = var.webapp_bucket_name
  acl           = "private"
  force_destroy = true
  attach_policy = true
  policy        = data.aws_iam_policy_document.webapp_bucket_policy.json

  # SPA applications requires error_document = index.html,
  # because they handle errors on their own.
  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  versioning = {
    enabled = false
  }
}
