output "cloudfront_id" {
  value = aws_cloudfront_distribution.hosting.id
}

output "lambda_edge_arn" {
  value = aws_lambda_function.lambda_edge.qualified_arn
}

output "webapp_s3_arn" {
  value = module.webapp_s3.this_s3_bucket_arn
}

output "static_s3_arn" {
  value = module.static_content_s3.this_s3_bucket_arn
}

output "hosted_zone_id" {
  value = aws_route53_zone.primary.id
}
