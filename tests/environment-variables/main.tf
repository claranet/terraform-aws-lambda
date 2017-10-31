terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_user" "test" {
  name = "tf-aws-lambda-test-environment-variables"
}

module "lambda" {
  source = "../../"

  function_name = "tf-aws-lambda-test-environment-variables"
  description   = "Test environment variables in tf-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  environment {
    variables {
      ARN = "${aws_iam_user.test.arn}"
    }
  }
}
