#############
# S3 Bucket #
#############
data "aws_iam_policy_document" "bucket_policy" {
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

  bucket        = "${var.static_content_bucket_name}-${var.env}"
  acl           = "private"
  force_destroy = true
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  versioning = {
    enabled = false
  }

  tags = {
    Environment = var.env
    Service     = var.service_name
  }
}
