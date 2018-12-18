resource "aws_lambda_function" "lambda" {
  count = "${! var.attach_vpc_config && ! var.attach_dead_letter_config && ! var.source_from_s3 ? 1 : 0}"

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Changes made to this resource should also be made to "lambda_with_*" below.
  # ----------------------------------------------------------------------------

  function_name                  = "${var.function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda.arn}"
  handler                        = "${var.handler}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.runtime}"
  timeout                        = "${local.timeout}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"

  # Use a generated filename to determine when the source code has changed.

  filename   = "${lookup(data.external.built.result, "filename")}"
  depends_on = ["null_resource.archive"]

  # The aws_lambda_function resource has a schema for the environment
  # variable, where the only acceptable values are:
  #   a. Undefined
  #   b. An empty list
  #   c. A list containing 1 element: a map with a specific schema
  # Use slice to get option "b" or "c" depending on whether a non-empty
  # value was passed into this module.

  environment = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}

resource "aws_lambda_function" "lambda_s3" {
  count = "${var.source_from_s3 && ! var.attach_vpc_config && ! var.attach_dead_letter_config ? 1 : 0}"

  function_name                  = "${var.function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda.arn}"
  handler                        = "${var.handler}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.runtime}"
  timeout                        = "${var.timeout}"
  tags                           = "${var.tags}"

  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${var.s3_key}"

  # The aws_lambda_function resource has a schema for the environment
  # variable, where the only acceptable values are:
  #   a. Undefined
  #   b. An empty list
  #   c. A list containing 1 element: a map with a specific schema
  # Use slice to get option "b" or "c" depending on whether a non-empty
  # value was passed into this module.

  environment = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}

# The vpc_config and dead_letter_config variables are lists of maps which,
# due to a bug or missing feature of Terraform, do not work with computed
# values. So here is a copy and paste of of the above resource for every
# combination of these variables.

resource "aws_lambda_function" "lambda_with_dl" {
  count = "${var.attach_dead_letter_config && ! var.attach_vpc_config && ! var.source_from_s3 ? 1 : 0}"

  dead_letter_config {
    target_arn = "${var.dead_letter_config["target_arn"]}"
  }

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Everything below here should match the "lambda" resource.
  # ----------------------------------------------------------------------------

  function_name                  = "${var.function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda.arn}"
  handler                        = "${var.handler}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.runtime}"
  timeout                        = "${local.timeout}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  filename                       = "${lookup(data.external.built.result, "filename")}"
  depends_on                     = ["null_resource.archive"]
  environment                    = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}

resource "aws_lambda_function" "lambda_with_vpc" {
  count = "${var.attach_vpc_config && ! var.attach_dead_letter_config && ! var.source_from_s3 ? 1 : 0}"

  vpc_config {
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
    subnet_ids         = ["${var.vpc_config["subnet_ids"]}"]
  }

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Everything below here should match the "lambda" resource.
  # ----------------------------------------------------------------------------

  function_name                  = "${var.function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda.arn}"
  handler                        = "${var.handler}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.runtime}"
  timeout                        = "${local.timeout}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  filename                       = "${lookup(data.external.built.result, "filename")}"
  depends_on                     = ["null_resource.archive"]
  environment                    = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}

resource "aws_lambda_function" "lambda_with_dl_and_vpc" {
  count = "${var.attach_dead_letter_config && var.attach_vpc_config && ! var.source_from_s3 ? 1 : 0}"

  dead_letter_config {
    target_arn = "${var.dead_letter_config["target_arn"]}"
  }

  vpc_config {
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
    subnet_ids         = ["${var.vpc_config["subnet_ids"]}"]
  }

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Everything below here should match the "lambda" resource.
  # ----------------------------------------------------------------------------

  function_name                  = "${var.function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda.arn}"
  handler                        = "${var.handler}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.runtime}"
  timeout                        = "${local.timeout}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  filename                       = "${lookup(data.external.built.result, "filename")}"
  depends_on                     = ["null_resource.archive"]
  environment                    = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}
