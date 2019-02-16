# terraform-aws-lambda

This Terraform module creates and uploads an AWS Lambda function and hides the ugly parts from you.

## Features

* Only appears in the Terraform plan when there are legitimate changes.
* Creates a standard IAM role and policy for CloudWatch Logs.
  * You can add additional policies if required.
* Zips up a source file or directory.
* Installs dependencies from `requirements.txt` for Python functions.
  * It only does this when necessary, not every time.

## Requirements

* Python 2.7 or higher
* Linux/Unix/Windows

## Usage

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
  attach_policy = true
  policy        = "${data.aws_iam_policy_document.lambda.json}"

  // Add a dead letter queue.
  attach_dead_letter_config = true
  dead_letter_config {
    target_arn = "${var.dead_letter_queue_arn}"
  }

  // Add environment variables.
  environment {
    variables {
      SLACK_URL = "${var.slack_url}"
    }
  }

  // Deploy into a VPC.
  attach_vpc_config = true
  vpc_config {
    subnet_ids         = ["${aws_subnet.test.id}"]
    security_group_ids = ["${aws_security_group.test.id}"]
  }
}
```

### NB - Multi-region usage

IAM and Lambda function names need to be globally unique within your account.
If you will be deploying this template to multiple regions, you must make the
function name unique per region, for example by setting
`function_name = "deployment-deploy-status-${data.aws_region.current.name}"`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attach\_dead\_letter\_config | Set this to true if using the dead_letter_config variable | string | `"false"` | no |
| attach\_policy | Set this to true if using the policy variable | string | `"false"` | no |
| attach\_vpc\_config | Set this to true if using the vpc_config variable | string | `"false"` | no |
| build\_command | The command that creates the Lambda package zip file | string | `"python build.py '$filename' '$runtime' '$source'"` | no |
| build\_paths | The files or directories used by the build command, to trigger new Lambda package builds whenever build scripts change | list | `<list>` | no |
| dead\_letter\_config | Dead letter configuration for the Lambda function | map | `<map>` | no |
| description | Description of what your Lambda function does | string | `"Managed by Terraform"` | no |
| enable\_cloudwatch\_logs | Set this to false to disable logging your Lambda output to CloudWatch Logs | string | `"true"` | no |
| environment | Environment configuration for the Lambda function | map | `<map>` | no |
| function\_name | A unique name for your Lambda function (and related IAM resources) | string | n/a | yes |
| handler | The function entrypoint in your code | string | n/a | yes |
| lambda\_at\_edge | Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function | string | `"false"` | no |
| memory\_size | Amount of memory in MB your Lambda function can use at runtime | string | `"128"` | no |
| policy | An addional policy to attach to the Lambda function | string | `""` | no |
| publish | Whether to publish creation/change as new Lambda Function Version | string | `"false"` | no |
| reserved\_concurrent\_executions | The amount of reserved concurrent executions for this Lambda function | string | `"0"` | no |
| runtime | The runtime environment for the Lambda function | string | n/a | yes |
| source\_path | The source file or directory containing your Lambda source code | string | n/a | yes |
| tags | A mapping of tags | map | `<map>` | no |
| timeout | The amount of time your Lambda function had to run in seconds | string | `"10"` | no |
| vpc\_config | VPC configuration for the Lambda function | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |
