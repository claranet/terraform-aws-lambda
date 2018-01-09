module "lambda" {
  source = "../../../"

  function_name = "terraform-aws-lambda-test-nested-modules-1"
  description   = "Test nested modules functionality in terraform-aws-lambda"
  handler       = "lambda1.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda1.py"
}
