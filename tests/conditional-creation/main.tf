terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "lambda" {
  source = "../../"

  create_resources = false

  function_name = "terraform-aws-lambda-test-cond-create"
  description   = "Test conditional creation of terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

}
