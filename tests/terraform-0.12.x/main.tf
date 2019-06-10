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
  prefix      = "terraform-aws-lambda-test-0.12.x"
}

module "lambda" {
  source = "../../"

  function_name = "${random_id.name.hex}"
  description   = "Test terraform-aws-lambda with Terraform 0.12.x"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"
}
