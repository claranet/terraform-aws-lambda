# tf-aws-lambda

This module creates a Lambda function and hides the ugly parts from you.

## Features

* Creates a standard IAM role and policy for CloudWatch Logs.
  * You can add additional policies if required.
* Zips up a source file or directory.
* Installs dependencies from `requirements.txt` for Python functions.
  * It only does this when the source code changes.
  * It only shows in the Terraform plan when the source code changes.

## Usage

### Single file Lambda script

```js
module "lambda" {
  source = "tf-aws-lambda"

  source_file = "${path.module}/lambda.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.lambda.json}"

  logs_retention_in_days = 90
  function_name          = "deployment-deploy-status"
  description            = "Deployment deploy status task"
  handler                = "main.lambda_handler"
  runtime                = "python3.6"
  timeout                = 300

  environment_variables {
    SLACK_URL = "${var.slack_url}"
  }
}
```

### Directory of Lambda scripts

```js
module "lambda" {
  source = "tf-aws-lambda"

  source_dir = "${path.module}/lambda/"

  ...
}
```
