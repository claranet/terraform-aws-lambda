output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = "${element(concat(aws_lambda_function.lambda.*.arn, aws_lambda_function.lambda_with_dl.*.arn, aws_lambda_function.lambda_with_vpc.*.arn, aws_lambda_function.lambda_with_dl_and_vpc.*.arn), 0)}"
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = "${element(concat(aws_lambda_function.lambda.*.function_name, aws_lambda_function.lambda_with_dl.*.function_name, aws_lambda_function.lambda_with_vpc.*.function_name, aws_lambda_function.lambda_with_dl_and_vpc.*.function_name), 0)}"
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = "${aws_iam_role.lambda.arn}"
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = "${aws_iam_role.lambda.name}"
}
