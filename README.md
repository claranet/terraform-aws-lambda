# tf-aws-lambda

This Terraform module creates and uploads an AWS Lambda function and hides the ugly parts from you.

## Features

* Only appears in the Terraform plan when there are legitimate changes.
* Creates a standard IAM role and policy for CloudWatch Logs.
  * You can add additional policies if required.
* Zips up a source file or directory.
* Installs dependencies from `requirements.txt` for Python functions.
  * It only does this when necessary, not every time.

## Requirements

* Python
* Linux/Unix

## Usage

```js
module "lambda" {
  source = "tf-aws-lambda"

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
