variable "region" {
  default = "eu-west-1"
}

module "hosting" {
  source       = "./modules/hosting"
  region       = var.region
  env          = "production"
  service_name = "hosting"

  static_content_bucket_name = "statics-demo"

  hosted_zone = "justagency.de."
  dns_address = "test.justagency.de"
}
