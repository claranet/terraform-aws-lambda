output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = "${lookup(element(concat(aws_lambda_function.lambda.*, aws_lambda_function.lambda_with_dl.*, aws_lambda_function.lambda_with_vpc.*, aws_lambda_function.lambda_with_dl_and_vpc.*), 0), "arn")}"
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = "${lookup(element(concat(aws_lambda_function.lambda.*, aws_lambda_function.lambda_with_dl.*, aws_lambda_function.lambda_with_vpc.*, aws_lambda_function.lambda_with_dl_and_vpc.*), 0), "function_name")}"
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = "${aws_iam_role.lambda.arn}"
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = "${aws_iam_role.lambda.name}"
}
