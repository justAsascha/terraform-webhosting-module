variable "env" {
  description = "The name of current environment."
}

variable "region" {
  default     = "eu-west-1"
  description = "The region where AWS operations will take place (default: Ireland)."
}

variable "service_name" {
  default     = "hosting"
  description = "Service name"
}

variable "static_content_bucket_name" {
  description = "The name of the s3 bucket for static content."
}

variable "hosted_zone" {
  description = "Name of hosted zone. (e.g. 'yourdns.tld.')"
}

variable "dns_address" {
  description = "DNS address to access web content."
}

variable "webapp_bucket_name" {
  description = "The name of the s3 bucket for single page application files."
}

variable "cloudfront_price_class" {
  description = "Cloudfront price class"
}

variable "whitelisted_cdirs" {
  description = "List of whitelisted CDIRs"
  type = list(object({
    value = string
    type  = string
  }))
}
