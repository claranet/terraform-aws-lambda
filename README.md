# tf-aws-lambda

This module creates a Lambda function. It saves you time by handling the zipping up the Lambda package, and creating an IAM role with a logging policy.

## Usage

### Single file Lambda script

```js
module "lambda" {
  source = "tf-aws-lambda"

  source_file = "${path.module}/lambda.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.lambda.json}"

  function_name = "deployment-deploy-status"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 300
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
