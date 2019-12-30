# terraform-aws-lambda

This Terraform module creates and uploads an AWS Lambda function and hides the ugly parts from you.

## Features

* Only appears in the Terraform plan when there are legitimate changes
* Creates a standard IAM role
  * Policy for CloudWatch Logs
  * Can add additional policies if required
* Zips up a source file or directory
* Installs dependencies from `requirements.txt` for Python functions
  * Only does this when necessary, not every time
* Uses Docker with [lambci docker image](https://hub.docker.com/r/lambci/lambda/) to ensure we get binaries for lambda environment when installing native extensions (numpy, scipy, pandas etc)
* Slims the lambda
  * Strips shared object files ca. 20% saving
  * Remove .py, use .pyc's = faster lambda and ca. 20% saving
  * Remove tests, info (minor savings, but why not)
  * Remove packages that will be available in AWS lambda environment (boto3 et al) ca. 50mb (uncompressed) saving

## Requirements

* Python 3.6 or higher
* Docker
* Linux/Unix/Windows

## Terraform version compatibility

| Module version | Terraform version |
|----------------|-------------------|
| 1.x.x          | 0.12.x            |
| 0.x.x          | 0.11.x            |

## Usage

### Upload your Lambda code directly using the API

This method is simplest and recommended for lambdas <50mb

```js
module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "deployment-deploy-status"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 300

  // Specify a file or directory for the source code.
  source_path = "${path.module}/lambda.py"

  // Attach a policy.
  policy = {
    json = data.aws_iam_policy_document.lambda.json
  }

  // Add a dead letter queue.
  dead_letter_config = {
    target_arn = aws_sqs_queue.dlq.arn
  }

  // Add environment variables.
  environment = {
    variables = {
      SLACK_URL = var.slack_url
    }
  }

  // Deploy into a VPC.
  vpc_config = {
    subnet_ids         = [aws_subnet.test.id]
    security_group_ids = [aws_security_group.test.id]
  }
}
```

### Upload your lambda code to s3 first, then create the Lambda from there

For lambdas over 50mb yet uncompressed still under 250mb, you can upload to s3 first, then create the lambda from there.

Details on this technique and limits https://hackernoon.com/exploring-the-aws-lambda-deployment-limits-9a8384b0bec3

To do so, specify the **s3_bucket_lambda_package** argument.

The module will create said bucket, and upload the lambda package there before deployment.

```js
module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  s3_bucket_lambda_package  = "123456789123-lambda-package-deploy-status"
  function_name             = "deployment-deploy-status"
  description               = "Deployment deploy status task"
  handler                   = "main.lambda_handler"
  runtime                   = "python3.6"
  timeout                   = 300

  // Specify a file or directory for the source code.
  source_path = "${path.module}/lambda.py"

  // Attach a policy.
  policy = {
    json = data.aws_iam_policy_document.lambda.json
  }

  // Add a dead letter queue.
  dead_letter_config = {
    target_arn = aws_sqs_queue.dlq.arn
  }

  // Add environment variables.
  environment = {
    variables = {
      SLACK_URL = var.slack_url
    }
  }

  // Deploy into a VPC.
  vpc_config = {
    subnet_ids         = [aws_subnet.test.id]
    security_group_ids = [aws_security_group.test.id]
  }
}
```


## Inputs

Inputs for this module are the same as the [aws_lambda_function](https://www.terraform.io/docs/providers/aws/r/lambda_function.html) resource with the following additional arguments:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| **source\_path** | The absolute path to a local file or directory containing your Lambda source code | `string` | | yes |
| s3_bucket_lambda_package | The name of the s3 bucket to create, in order to upload the zipped lambda package and deploy from there (allows larger lambdas) | `string` | null | no |
| build\_command | The command to run to create the Lambda package zip file | `string` | `"python build.py '$filename' '$runtime' '$source'"` | no |
| build\_paths | The files or directories used by the build command, to trigger new Lambda package builds whenever build scripts change | `list(string)` | `["build.py"]` | no |
| cloudwatch\_logs | Set this to false to disable logging your Lambda output to CloudWatch Logs | `bool` | `true` | no |
| lambda\_at\_edge | Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function | `bool` | `false` | no |
| policy | An additional policy to attach to the Lambda function role | `object({json=string})` | | no |

The following arguments from the [aws_lambda_function](https://www.terraform.io/docs/providers/aws/r/lambda_function.html) resource are not supported:

* filename (use source\_path instead)
* role (one is automatically created)
* s3_bucket
* s3_key
* s3_object_version
* source_code_hash (changes are handled automatically)

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |
