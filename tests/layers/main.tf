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

  function_name = "terraform-aws-lambda-test-layers"
  description   = "Test layers in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.7"

  layers = [
    "arn:aws:lambda:::awslayer:AmazonLinux1803",         # https://aws.amazon.com/blogs/compute/upcoming-updates-to-the-aws-lambda-execution-environment/
    "arn:aws:lambda:eu-west-1:553035198032:layer:git:5", # https://github.com/lambci/git-lambda-layer
  ]

  source_path = "${path.module}/lambda.py"
}
