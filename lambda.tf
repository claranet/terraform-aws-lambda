resource "aws_lambda_function" "lambda_without_vpc" {
  count = "${var.attach_vpc_config ? 0 : 1}"

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Changes made to this resource should also be made to lambda_with_vpc.
  # ----------------------------------------------------------------------------

  function_name = "${var.function_name}"
  description   = "${var.description}"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"
  timeout       = "${var.timeout}"
  tags          = "${var.tags}"

  # Use a generated filename to determine when the source code has changed.

  filename = "${lookup(data.external.archive.result, "filename")}"

  # Depend on the null_resource to build the file when required.

  depends_on = ["null_resource.archive"]

  # The aws_lambda_function resource has a schema for the environment
  # variable, where the only acceptable values are:
  #   a. Undefined
  #   b. An empty list
  #   c. A list containing 1 element: a map with a specific schema
  # Use slice to get option "b" or "c" depending on whether a non-empty
  # value was passed into this module.

  environment = "${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"
}

resource "aws_lambda_function" "lambda_with_vpc" {
  count = "${var.attach_vpc_config ? 1 : 0}"

  # Add the VPC config. I couldn't find any other way to make this optional
  # and still work with computed values, so copy/paste the whole resource.
  vpc_config {
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
    subnet_ids         = ["${var.vpc_config["subnet_ids"]}"]
  }

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Everything below here should match the lambda_without_vpc resource.
  # ----------------------------------------------------------------------------

  function_name = "${var.function_name}"
  description   = "${var.description}"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"
  timeout       = "${var.timeout}"
  tags          = "${var.tags}"
  filename      = "${lookup(data.external.archive.result, "filename")}"
  depends_on    = ["null_resource.archive"]
  environment   = "${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"
}
