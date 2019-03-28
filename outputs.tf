output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = "${element(concat(aws_lambda_function.lambda.*.arn, aws_lambda_function.lambda_with_dl.*.arn, aws_lambda_function.lambda_with_vpc.*.arn, aws_lambda_function.lambda_with_dl_and_vpc.*.arn), 0)}"
}

output "function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = "${element(concat(aws_lambda_function.lambda.*.invoke_arn, aws_lambda_function.lambda_with_dl.*.invoke_arn, aws_lambda_function.lambda_with_vpc.*.invoke_arn, aws_lambda_function.lambda_with_dl_and_vpc.*.invoke_arn), 0)}"
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = "${element(concat(aws_lambda_function.lambda.*.function_name, aws_lambda_function.lambda_with_dl.*.function_name, aws_lambda_function.lambda_with_vpc.*.function_name, aws_lambda_function.lambda_with_dl_and_vpc.*.function_name), 0)}"
}

output "function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = "${element(concat(aws_lambda_function.lambda.*.qualified_arn, aws_lambda_function.lambda_with_dl.*.qualified_arn, aws_lambda_function.lambda_with_vpc.*.qualified_arn, aws_lambda_function.lambda_with_dl_and_vpc.*.qualified_arn), 0)}"
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = "${aws_iam_role.lambda.arn}"
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = "${aws_iam_role.lambda.name}"
}
