terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "../../"

  source_file = "${path.module}/lambda.py"

  function_name = "tf-aws-lambda-test-vpc-config"
  description   = "Test vpc-config in tf-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  vpc_config {
    subnet_ids         = [] # put values here when testing
    security_group_ids = [] # put values here when testing
  }
}
