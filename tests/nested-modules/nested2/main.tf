module "lambda" {
  source = "../../../"

  function_name = "terraform-aws-lambda-test-nested-modules-2"
  description   = "Test nested modules functionality in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda2"
}
