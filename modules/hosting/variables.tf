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

variable "static_dns_name" {
  description = "The dns name for static content"
}
