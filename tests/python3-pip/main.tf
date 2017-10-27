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

  source_dir = "${path.module}/lambda"

  function_name = "tf-aws-lambda-test-build"
  description   = "Test python3 pip functionality in tf-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30
}
