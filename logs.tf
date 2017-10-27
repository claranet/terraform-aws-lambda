resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "${var.function_name}"
  retention_in_days = "${var.logs_retention_in_days}"
  tags              = "${var.tags}"
}
