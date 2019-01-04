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

  function_name = "terraform-aws-lambda-test-custom-build-script"
  description   = "Test custom build script functionality in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.7"

  source_path = "${path.module}/lambda"
  build_script = "${path.module}/lambda/build.sh"
}
