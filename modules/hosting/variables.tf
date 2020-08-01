variable "region" {
  default     = "eu-west-1"
  description = "The region where AWS operations will take place (default: Ireland)."
}

variable "static_content_bucket_name" {
  description = "The name of the s3 bucket for static content."
}

variable "hosted_zone" {
  description = "Name of hosted zone. (e.g. 'yourdns.tld.')"
}

variable "dns_address" {
  description = "DNS address for web content."
}

variable "webapp_bucket_name" {
  description = "The name of the s3 bucket for single page application files."
}

variable "cloudfront_price_class" {
  description = "Cloudfront price class"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM Certificate"
}

variable "basic_auth_username" {
  description = "Basic Auth Username"
}

variable "basic_auth_password" {
  description = "Basic Auth secret"
}

variable "allowlist_cdirs" {
  description = "List of allowlisted CDIRs"
  type = list(object({
    value = string
    type  = string
  }))
}
