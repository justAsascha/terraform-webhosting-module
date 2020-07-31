variable "region" {
  default = "eu-west-1"
}

module "hosting" {
  source       = "./modules/hosting"
  region       = var.region
  env          = "production"
  service_name = "hosting"

  static_content_bucket_name = "statics-demo"
  static_dns_name            = "static.tld"
}
