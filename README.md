# tf-aws-lambda

This module creates a Lambda function. It saves you time by handling the zipping up the Lambda package, and creating an IAM role with a logging policy.

## Usage

### Single file Lambda script

```js
module "lambda" {
  source = "../../../modules/tf-aws-lambda"

  source_file = "${path.module}/lambda.py"

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
  source = "../../../modules/tf-aws-lambda"

  source_dir = "${path.module}/lambda/"

  function_name = "deployment-deploy-status"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 300
}
```

### Attaching a custom policy

```js
data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "${module.lambda.function_name}"
  policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${module.lambda.function_name}"
  roles      = ["${module.lambda.role_name}"]
  policy_arn = "${aws_iam_policy.lambda.arn}"
}
```
