# Webhosting Module

Tterraform module to distribute static content from one bucket for /static/ paths, and as default to serve a simple 'hello-world' javascript SPA application from a different bucket. Distribution is only accessible for certain IP ranges.

The module:
- take the ARN of an ACM certificate as a parameter.
- create the necessary S3 bucket with best practices configuration.
- create route53 HostedZone.
- create CloudFront web distribution.
- create relevant DNS entries pointing to the distribution.
- IP protection implemented as desired.
- implements basic authentication protection for the distribution. (Can be a static username + password)

- Please document the functionality and how to run the application to the best of your ability in the README.md.
- Testing is encouraged.
- Please provide the code in a publicly accessible git repository.

# Requirements

- Go (requires version >=1.13) for terratest
- terraform (https://www.terraform.io/)
- aws-cli (https://aws.amazon.com/de/cli/) 

# How To Run
See ./main.tf for example usage.

Example:

```
module "hosting" {
  source = "./modules/hosting"
  region = "eu-west-1"

  static_content_bucket_name = "epilot-static-demo"
  webapp_bucket_name         = "epilot-webapp-demo"

  hosted_zone            = "yourdomain.tld."
  dns_address            = "yourdomain.tld"
  cloudfront_price_class = "PriceClass_100"
  acm_certificate_arn    = "xxxxxxxxxxxxxxx"

  basic_auth_username = "demo"
  basic_auth_password = "secret"

  allowlist_cdirs = [
    { value = "100.100.100.100/32", type = "IPV4" },
    { value = "100.100.100.101/32", type = "IPV4" },
  ]
}
```

## Init Terraform Modules
`$ terraform init` 

## Show Changes
`$ terraform plan` 

## Apply Changes
`$ terraform apply`

## Upload files (example)
- Create folder 'static' in static bucket and upload files from ./testfiles/static
- Upload files from ./testfiles/webapp/dist/webapp to webapp s3 bucket.

## Configure NS Records
- You need to configure NS records for your domain. 
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html

## Clean Environment
`$ terraform destroy`

`$ cd test`

`$ go test -v -timeout 30m`

# Hosting Module Description

## Inputs

| Name                       | Description                                                         | Type     | Default     | Required |
|----------------------------|---------------------------------------------------------------------|----------|-------------|:--------:|
| region                     | The region where AWS operations will take place (default: Ireland). | `string` | `eu-west-1` |   yes    |
| static_content_bucket_name | The name of the s3 bucket for static content.                       | `string` | -           |   yes    |
| webapp_bucket_name         | The name of the s3 bucket for single page application files.        | `string` | -           |   yes    |
| hosted_zone                | Name of hosted zone. (e.g. 'yourdns.tld.')                          | `string` | -           |   yes    |
| dns_address                | DNS address for web content.                                        | `string` | -           |   yes    |
| cloudfront_price_class     | Cloudfront price class                                              | `string` | -           |   yes    |
| acm_certificate_arn        | ARN of ACM Certificate                                              | `string` | -           |   yes    |
| basic_auth_username        | Basic Auth Username                                                 | `string` | -           |   yes    |
| basic_auth_password        | Basic Auth secret                                                   | `string` | -           |   yes    |
| allowlist_cdirs            | List of allowlisted CDIRs                                           | `{}`     | -           |   yes    |


## Outputs

| Name            | Description                                                    |
|-----------------|----------------------------------------------------------------|
| cloudfront_id   | ID of generated Cloudfront distribution                        |
| lambda_edge_arn | ARN of generated Lambda@Edge for basic authentication handling |
| webapp_s3_arn   | ARN of generated S3 Bucket for webapp                          |
| static_s3_arn   | ARN of generated S3 Bucket for static files                    |
| hosted_zone_id  | ID of generated hosted zone                                    |
