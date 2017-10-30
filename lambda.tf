resource "aws_lambda_function" "lambda" {
  function_name = "${var.function_name}"
  description   = "${var.description}"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"
  timeout       = "${var.timeout}"
  tags          = "${var.tags}"

  # Use a generated filename to determine when the source code has changed,
  filename = "${lookup(data.external.archive.result, "filename")}"

  # Depend on the null_resource to build the file when required.
  depends_on = ["null_resource.archive"]

  # The aws_lambda_function resource has a schema for the
  # following variables, so the only acceptable values are:
  #   a. Undefined
  #   b. An empty list
  #   c. A list containing 1 element: a map with a specific schema
  # Use slice to get option "b" or "c" depending on whether a non-empty
  # value was passed into this module.

  environment = "${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"
  vpc_config  = "${slice( list(var.vpc_config), 0, length(var.vpc_config) == 0 ? 0 : 1 )}"
}
