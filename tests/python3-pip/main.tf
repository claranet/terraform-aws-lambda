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

  function_name = "terraform-aws-lambda-test-python3-pip"
  description   = "Test python3 pip functionality in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda"
}
