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


# How To Run

## Show Changes
`$ terraform plan` 

## Apply Changes
`$ terraform apply`

## Configure NS Records
- You need to configure NS records for your domain. 
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html


## Clean Environment
`$ terraform destroy`

## Notes
I would highly recommend to use an exsisting hosted zone within a module and keep generation of hosted zones isolated, because they need longer provisioning time due to DNS propagination.