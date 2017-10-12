data "archive_file" "lambda_file" {
  count       = "${var.source_file != "" ? 1 : 0}"
  type        = "zip"
  source_file = "${var.source_file}"
  output_path = ".terraform/lambda-${var.function_name}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}.zip"
}

data "archive_file" "lambda_dir" {
  count       = "${var.source_dir != "" ? 1 : 0}"
  type        = "zip"
  source_dir  = "${var.source_dir}"
  output_path = ".terraform/lambda-${var.function_name}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${var.function_name}"
  description      = "${var.description}"
  filename         = "${element(concat(data.archive_file.lambda_file.*.output_path, data.archive_file.lambda_dir.*.output_path), 0)}"
  source_code_hash = "${element(concat(data.archive_file.lambda_file.*.output_base64sha256, data.archive_file.lambda_dir.*.output_base64sha256), 0)}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "${var.handler}"
  runtime          = "${var.runtime}"
  timeout          = "${var.timeout}"
  tags             = "${var.tags}"
}
