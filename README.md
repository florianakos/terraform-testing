# terraform-testing

A project that combines creation of a new terraform module and testing it via AWS and Localstack using Go's built-in test capabilities.

## requirements

* go
* terraform
* localstack
* aws creds

The terraform module was written to take care of S3 and KMS permissions necessary for an IAM role to carry out it's intended functions. **Motivation**: at work I've recently run into an issue where too many policies were being attached to a single role, and so with this module it's possible to collect all necessary S3 and KMS permissions in a single policy which is then attached to the IAM Role (it's possible to grant granular RO/RW permissions to specific prefixes or objects in an S3 bucket).

## Running the tests

There are 3 different ways of running the tests

### manually via localstack

The terraform code which utilizes the TF module is already prepared to use the localstack endpoints in the provider configuration.

```shell
cd test/terraform/localstack
docker-compose up
terraform init
terraform apply
terraform destroy
```

If localstack gets stuck in docker-compose you can reset it via `docker-compose down -v --rmi all --remove-orphans`.

### manually via aws

This assumes a local AWS profile `personal-aws` is already configured and is available to use for running this test. 

```shell
cd test/terraform/aws
terraform init
terraform apply
terraform destroy
```

Furtheromre, this test assumes that a bucket is already available in the AWS account for storing the terraform state remogtely!

```hcl
  backend "s3" {
    bucket = "terraform-testing-via-go"
    key = "test/s3-authz-test/terraform.tfstate"
    region = "eu-central-1"
    profile = "personal-aws"
  }
```

### automated via Go

This option relies on the `/test/terraform/aws` but runs it automatically via the Go testing package.

```shell
 ▶ cd test/go
 ▶ go test
TestTerraform 2020-07-12T17:57:21+02:00 logger.go:66: Running command terraform with args [init -upgrade=false]
TestTerraform 2020-07-12T17:57:21+02:00 logger.go:66: Initializing modules...
TestTerraform 2020-07-12T17:57:21+02:00 logger.go:66: - s3_authz in ../../../tf-module-s3-auth
TestTerraform 2020-07-12T17:57:21+02:00 logger.go:66: Initializing the backend...
TestTerraform 2020-07-12T17:57:23+02:00 logger.go:66: Successfully configured the backend "s3"! Terraform will automatically
TestTerraform 2020-07-12T17:57:29+02:00 logger.go:66: - s3_authz in ../../../tf-module-s3-auth
...
TestTerraform 2020-07-12T17:57:46+02:00 logger.go:66: Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
...
TestTerraform 2020-07-12T17:58:04+02:00 logger.go:66: 
TestTerraform 2020-07-12T17:58:04+02:00 logger.go:66: Destroy complete! Resources: 5 destroyed.
PASS
ok      github.com/florianakos/terraform-testing/tests  43.191s
```

## Conclusion

Testing via `localstack` is great as long as you are working with AWS and the targeted service is supported by localstack. It runs much much faster thanks to the fact that localhost is much closer to you than the cloud API endpoints. 

Go is awesome! Terraform is awesome too! :) 
