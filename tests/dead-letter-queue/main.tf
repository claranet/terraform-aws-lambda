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
  prefix      = "terraform-aws-lambda-dlq-"
}

resource "aws_sqs_queue" "dlq" {
  name = random_id.name.hex
}

module "lambda" {
  source = "../../"

  function_name = random_id.name.hex
  description   = "Test dead letter queue in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  dead_letter_config = {
    target_arn = aws_sqs_queue.dlq.arn
  }
}
