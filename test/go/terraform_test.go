package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraform(t *testing.T) {
	// some initial config setup
	roleName := fmt.Sprintf("developer-role-test-%s", strings.ToLower(random.UniqueId()))
	bucketName := fmt.Sprintf("developer-bucket-test-%s", strings.ToLower(random.UniqueId()))
	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform/aws",
		Vars: map[string]interface{}{
			"iam_role_name":  roleName,
			"s3_bucket_name": bucketName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "eu-central-1",
		},
		NoColor: false,
	}
	// deferred Terraform DESTROY to clean up afterwards
	defer terraform.Destroy(t, terraformOptions)
	// Terraform Init and Apply
	terraform.InitAndApply(t, terraformOptions)
	// Assert that the outputs from resource creation matches expected output
	assert.Equal(t, roleName, terraform.Output(t, terraformOptions, "iam_role_name"))
	assert.Equal(t, bucketName, terraform.Output(t, terraformOptions, "s3_bucket_name"))
}
