resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.create_log_group == true ? 1 : 0
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention
  kms_key_id        = var.log_group_kms_key_id
  tags              = var.log_group_tags
}