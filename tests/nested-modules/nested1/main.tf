module "lambda" {
  source = "../../../"

  function_name = "tf-aws-lambda-test-nested-modules-1"
  description   = "Test nested modules functionality in tf-aws-lambda"
  handler       = "lambda1.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda1.py"
}
