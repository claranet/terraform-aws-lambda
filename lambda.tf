resource "aws_lambda_function" "lambda" {
  count                          = var.s3_bucket_lambda_package != null ? 0 : 1
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
  filename = data.external.built.result.filename

  depends_on = [null_resource.archive]

  # Add dynamic blocks based on variables.

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config == null ? [] : [var.dead_letter_config]
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [var.tracing_config]
    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }
}

# Note the module must manage the s3 bucket, rather than this be created in the caller then passed in
# It's currently a constraint of Terraform when using the conditional (count hack)
# within a module, it can't plan when this depends on a variable that has been passed in
# since TF apparently can't predict such values until apply-time
# see https://github.com/hashicorp/terraform/issues/12570
resource "aws_s3_bucket" "lambda_package" {
  count         = var.s3_bucket_lambda_package != null ? 1 : 0
  bucket        = var.s3_bucket_lambda_package
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    id      = "auto-delete"
    enabled = true
    expiration {
      days = local.s3_lifecycle_delete_days
    }
  }
}

resource "aws_lambda_function" "lambda_from_s3" {
  count                          = var.s3_bucket_lambda_package != null ? 1 : 0
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
  s3_bucket = aws_s3_bucket.lambda_package[0].id
  s3_key    = lookup(data.external.archive.result, "filename")

  depends_on = [null_resource.archive, aws_s3_bucket_object.lambda_package[0]]

  # Add dynamic blocks based on variables.

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config == null ? [] : [var.dead_letter_config]
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [var.tracing_config]
    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }
}
