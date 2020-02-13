terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "terraform-aws-lambda-policy-"
}

resource "aws_sqs_queue" "test" {
  name = random_id.name.hex
}

data "aws_iam_policy_document" "computed" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.test.arn,
    ]
  }
}

data "aws_iam_policy_document" "known" {
  statement {
    effect = "Deny"

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      "*",
    ]
  }
}

module "lambda_with_computed_policy" {
  source = "../../"

  function_name = "${random_id.name.hex}-computed"
  description   = "Test attaching policy in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"

  source_path = "${path.module}/lambda.py"

  policy = {
    json = data.aws_iam_policy_document.computed.json
  }
}


module "lambda_with_known_policy" {
  source = "../../"

  function_name = "${random_id.name.hex}-known"
  description   = "Test attaching policy in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"

  source_path = "${path.module}/lambda.py"

  policy = {
    json = data.aws_iam_policy_document.known.json
  }
}


module "lambda_without_policy" {
  source = "../../"

  function_name = "${random_id.name.hex}-without"
  description   = "Test attaching policy in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"

  source_path = "${path.module}/lambda.py"
}
