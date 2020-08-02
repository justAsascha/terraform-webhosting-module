# Challenge Description

Write a terraform module to distribute static content from one bucket for /static/ paths, and as default to serve a simple 'hello-world' javascript SPA application from a different bucket. Make sure that the distribution is only accessible for certain IP ranges.

The module should:
- take the ARN of an ACM certificate as a parameter.
- create the necessary S3 bucket with best practices configuration.
- create route53 HostedZone.
- create CloudFront web distribution.
- create relevant DNS entries pointing to the distribution.
- IP protection implemented as desired.
- (Bonus): implement basic authentication protection for the distribution. (Can be a static username + password)

- Please document the functionality and how to run the application to the best of your ability in the README.md.
- Testing is encouraged.
- Please provide the code in a publicly accessible git repository.

# Live Demo
SPA: https://justagency.de/

static image: https://justagency.de/static/handsomeguy.png

Username: `demo`

Password: `secret` 

# Requirements

- Go (requires version >=1.13) for terratest
- terraform (https://www.terraform.io/)
- aws-cli (https://aws.amazon.com/de/cli/) 

# How To Run
See ./main.tf for example usage.

## Init Terraform Modules
`$ terraform init` 

## Show Changes
`$ terraform plan` 

## Apply Changes
`$ terraform apply`

## Upload files (example)
- Create folder 'static' in static bucket and upload files from ./testfiles/static
- Upload files from ./testfiles/webapp/dist/webapp

## Configure NS Records
- You need to configure NS records for your domain. 
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html

## Clean Environment
`$ terraform destroy`

# Testing
I've used terratest for testing (https://terratest.gruntwork.io/)

`$ cd test`

`$ go test -v -timeout 30m`

# Notes
I used my domain "justagency.de" which I had already purchased in past. 
I would highly recommend to pass hosted zone as a parameter to keep generation of hosted zones isolated. So we have more control of services which longer provisioning time.

I've added /dist folder of the angular SPA application. This is just for demo purpose, so you guys won't need to install nodejs and build it.

Due to lack of time I couldn't manage to setup proper tests. I hope I gave you an expression what I've tried to achieve. 

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
