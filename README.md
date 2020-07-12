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

### manually via aws

This assumes a local AWS profile `personal-aws` is already configured and is available to use for running this test.

```shell
cd test/terraform/aws
terraform init
terraform apply
terraform destroy
```

### automated via Go

This option relies on the `/test/terraform/aws` but runs it automatically via the Go testing package.

```shell
cd test/go
go test
```

## Conclusion

Go is awesome! Terraform is awesome too... :)
