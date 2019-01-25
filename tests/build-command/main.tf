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

  function_name = "terraform-aws-lambda-test-build-command"
  description   = "Test custom build command functionality in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.7"

  source_path = "${path.module}/lambda/src"

  build_command = "${path.module}/lambda/build.sh '$filename' '$runtime' '$source'"
  build_paths   = ["${path.module}/lambda/build.sh"]
}
