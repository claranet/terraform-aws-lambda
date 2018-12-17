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
  prefix      = "terraform-aws-lambda-s3-"
}

resource "aws_s3_bucket" "b" {
  bucket = "${random_id.name.hex}"
  acl    = "private"
}
data "archive_file" "l" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket_object" "o" {
  bucket = "${aws_s3_bucket.b.id}"
  key    = "lambda.zip"
  source = "${path.module}/lambda.zip"
}

module "lambda" {
  source = "../../"

  function_name                  = "terraform-aws-lambda-test-s3-bucket-key"
  description                    = "Test S3 bucket and key in terraform-aws-lambda"
  handler                        = "lambda.lambda_handler"
  memory_size                    = 128
  reserved_concurrent_executions = 3
  runtime                        = "python3.6"
  timeout                        = 30

  source_from_s3 = true
  s3_bucket      = "${aws_s3_bucket.b.id}"
  s3_key         = "${aws_s3_bucket_object.o.id}"
}
