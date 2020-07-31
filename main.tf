terraform {
  required_version = ">= 0.12.28"
}

provider "aws" {
  version = "~> 2.35"
  region  = var.region
}
# used to fetch ssl certificates 
# (must be defined in us-east-1)
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

variable "region" {
  default = "eu-west-1"
}

# example showcase
module "hosting" {
  source       = "./modules/hosting"
  region       = var.region
  env          = "production"
  service_name = "hosting"

  static_content_bucket_name = "epilot-statics-demo"
  webapp_bucket_name         = "epilot-webapp-demo"

  hosted_zone            = "justagency.de."
  dns_address            = "test.justagency.de"
  cloudfront_price_class = "PriceClass_100"

  whitelisted_cdirs = [
    # my private ip, sometimes :-)
    { value = "5.146.105.103/32", type = "IPV4" },
  ]
}
