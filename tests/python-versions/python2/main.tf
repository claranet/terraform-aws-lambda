terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "lambda_python2" {
  source = "../../../"

  function_name = "terraform-aws-lambda-test-python2-from-python2"
  description   = "Test python2 runtime from python2 environment in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python2.7"
  timeout       = 5

  source_path = "${path.module}/../lambda"
}

module "lambda_python3" {
  source = "../../../"

  function_name = "terraform-aws-lambda-test-python3-from-python2"
  description   = "Test python3 runtime from python2 environment in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  timeout       = 5

  source_path = "${path.module}/../lambda"
}
