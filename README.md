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

## Terraform version compatibility

| Module version | Terraform version |
|----------------|-------------------|
| 1.x.x          | 0.12.x            |
| 0.x.x          | 0.11.x            |


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

  // Add additional trusted entities for assuming roles (trust relationships).
  trusted_entities = ["events.amazonaws.com", "s3.amazonaws.com"]

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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| external | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| dead\_letter\_config | n/a | <pre>object({<br>    target_arn = string<br>  })</pre> | n/a | yes |
| description | n/a | `string` | n/a | yes |
| environment | n/a | <pre>object({<br>    variables = map(string)<br>  })</pre> | n/a | yes |
| function\_name | n/a | `string` | n/a | yes |
| handler | n/a | `string` | n/a | yes |
| kms\_key\_arn | n/a | `string` | n/a | yes |
| layers | n/a | `list(string)` | n/a | yes |
| log\_group\_kms\_key\_id | The ID of a KMS key to use for encrypting the logs for the log group used by the Lambda if create\_log\_group is enabled. | `string` | n/a | yes |
| log\_group\_retention | The retention time of the Cloudwatch Log group that the Lambda logs to if create\_log\_group is enabled. | `string` | n/a | yes |
| log\_group\_tags | The tags to assign to the log group for the Lambda if create\_log\_group is enabled. This needs to be a list of maps of strings. | `list(map(string))` | n/a | yes |
| memory\_size | n/a | `number` | n/a | yes |
| policy | An additional policy to attach to the Lambda function role | <pre>object({<br>    json = string<br>  })</pre> | n/a | yes |
| reserved\_concurrent\_executions | n/a | `number` | n/a | yes |
| runtime | n/a | `string` | n/a | yes |
| source\_path | The absolute path to a local file or directory containing your Lambda source code | `string` | n/a | yes |
| tags | n/a | `map(string)` | n/a | yes |
| tracing\_config | n/a | <pre>object({<br>    mode = string<br>  })</pre> | n/a | yes |
| vpc\_config | n/a | <pre>object({<br>    security_group_ids = list(string)<br>    subnet_ids         = list(string)<br>  })</pre> | n/a | yes |
| build\_command | The command to run to create the Lambda package zip file | `string` | `"python build.py '$filename' '$runtime' '$source'"` | no |
| build\_paths | The files or directories used by the build command, to trigger new Lambda package builds whenever build scripts change | `list(string)` | <pre>[<br>  "build.py"<br>]</pre> | no |
| cloudwatch\_logs | Set this to false to disable logging your Lambda output to CloudWatch Logs | `bool` | `true` | no |
| create\_log\_group | Whether or not to create the log group for the Lambda function. If the Lambda has been ran with logging enabled prior to this option being enabled Terraform will fail as the log group will already exist. In this case you will have to import the log group using a command like: terraform import module.lambda.aws\_cloudwatch\_log\_group.lambda /aws/lambda/lambda\_function\_name. Also note that if you disable this option or remove the module Terraform will want to remove the log group and it's associated logs. To keep the log group and its logs please ensure that you either remove module.lambda.aws\_cloudwatch\_log\_group.lambda from the state or move it to somewhere else in the state using either terraform state rm or terraform state mv. | `bool` | `false` | no |
| lambda\_at\_edge | Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function | `bool` | `false` | no |
| publish | n/a | `bool` | `false` | no |
| timeout | n/a | `number` | `3` | no |
| trusted\_entities | Lambda function additional trusted entities for assuming roles (trust relationship) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_arn | The ARN of the log group created for this Lambda if logging is enabled. |
| cloudwatch\_log\_group\_name | The name of the log group created for this Lambda if logging is enabled. |
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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
