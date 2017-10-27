resource "aws_lambda_function" "lambda" {
  function_name = "${var.function_name}"
  description   = "${var.description}"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"
  timeout       = "${var.timeout}"
  tags          = "${var.tags}"

  environment {
    variables = "${var.environment_variables}"
  }

  # Use a generated filename to determine when the source code has changed,
  filename = "${lookup(data.external.archive.result, "filename")}"

  # Depend on the null_resource to build the file when required.
  depends_on = ["null_resource.archive"]
}
