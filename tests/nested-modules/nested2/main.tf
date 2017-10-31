module "lambda" {
  source = "../../../"

  function_name = "tf-aws-lambda-test-nested-modules-2"
  description   = "Test nested modules functionality in tf-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda2"
}
