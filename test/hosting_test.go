package test

import (
	"fmt"
	"testing"

	externalip "github.com/glendc/go-external-ip"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestHostingModule(t *testing.T) {
	// ugly hack to retrieve external IP
	consensus := externalip.DefaultConsensus(nil, nil)
	ip, err := consensus.ExternalIP()
	if err == nil {
		fmt.Println(ip.String())
	}

	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../modules/hosting",
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":                     "eu-west-1",
			"static_content_bucket_name": "epilot-static-test",
			"webapp_bucket_name":         "epilot-webapp-test",
			"hosted_zone":                "justagency.de.",
			"dns_address":                "justagency.de",
			"cloudfront_price_class":     "PriceClass_100",
			"acm_certificate_arn":        "arn:aws:acm:us-east-1:483794430365:certificate/da3809c2-e943-463d-9af9-542411678b8f",
			"basic_auth_username":        "demo",
			"basic_auth_password":        "secret",
			"allowlist_cdirs":            fmt.Sprintf("[{\"value\"=\"%s/32\",\"type\"=\"IPV4\"}]", ip.String()),
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	cloudfrontID := terraform.Output(t, terraformOptions, "cloudfront_id")
	lambdaEdgeArn := terraform.Output(t, terraformOptions, "lambda_edge_arn")
	webappS3Arn := terraform.Output(t, terraformOptions, "webapp_s3_arn")
	staticS3Arn := terraform.Output(t, terraformOptions, "static_s3_arn")
	hostedZoneID := terraform.Output(t, terraformOptions, "hosted_zone_id")
	assert.NotEmpty(t, cloudfrontID)
	assert.NotEmpty(t, lambdaEdgeArn)
	assert.NotEmpty(t, webappS3Arn)
	assert.NotEmpty(t, staticS3Arn)
	assert.NotEmpty(t, hostedZoneID)

	// TODO: file upload test webapp & static files
	// TODO: test basic authentication
	// // Run `terraform output` to get the value of an output variable
	// instanceURL := "https://justagency.de"

	// // Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	// tlsConfig := tls.Config{}

	// // It can take a minute or so for the Instance to boot up, so retry a few times
	// maxRetries := 30
	// timeBetweenRetries := 5 * time.Second

	// // Verify that we get back a 200 OK 
	// http_helper.HttpGetWithRetry(t, instanceURL, &tlsConfig, 200, maxRetries, timeBetweenRetries)
}
