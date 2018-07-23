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

  function_name                  = "terraform-aws-lambda-test-python-cmd"
  description                    = "Test python_cmd in terraform-aws-lambda"
  handler                        = "lambda.lambda_handler"
  memory_size                    = 256
  reserved_concurrent_executions = 3
  runtime                        = "python3.6"
  timeout                        = 30

  python_cmd = ["python"]

  source_path = "${path.module}/lambda.py"
}
