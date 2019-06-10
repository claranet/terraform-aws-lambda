terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "test" {
  cidr_block = "10.255.255.0/24"

  tags = {
    Name = "terraform-aws-lambda-test-vpc-config"
  }
}

resource "aws_subnet" "test" {
  vpc_id     = aws_vpc.test.id
  cidr_block = aws_vpc.test.cidr_block
}

resource "aws_security_group" "test" {
  name   = "terraform-aws-lambda-test-vpc-config"
  vpc_id = aws_vpc.test.id
}

module "lambda" {
  source = "../../"

  function_name = "terraform-aws-lambda-test-vpc-config"
  description   = "Test vpc-config in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  vpc_config = {
    subnet_ids         = [aws_subnet.test.id]
    security_group_ids = [aws_security_group.test.id]
  }
}
