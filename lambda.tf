resource "aws_lambda_function" "lambda" {

  function_name                  = var.function_name
  description                    = var.description
  role                           = aws_iam_role.lambda.arn
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = var.runtime
  layers                         = var.layers
  timeout                        = local.timeout
  publish                        = local.publish
  tags                           = var.tags

  # Use a generated filename to determine when the source code has changed.

  filename   = data.external.built.result.filename
  depends_on = [null_resource.archive]

  # Add dynamic blocks based on variables.

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config == null ? [] : [1]
    content {
      target_arn = var.dead_letter_config.target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [1]
    content {
      variables = var.environment.variables
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [1]
    content {
      mode = var.tracing_config.mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [1]
    content {
      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids
    }
  }
}