output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = element(concat(aws_lambda_function.lambda.*.arn, aws_lambda_function.lambda_from_s3.*.arn), 0)
}

output "function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = element(concat(aws_lambda_function.lambda.*.invoke_arn, aws_lambda_function.lambda_from_s3.*.invoke_arn), 0)
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = element(concat(aws_lambda_function.lambda.*.function_name, aws_lambda_function.lambda_from_s3.*.function_name), 0)
}

output "function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = element(concat(aws_lambda_function.lambda.*.qualified_arn, aws_lambda_function.lambda_from_s3.*.qualified_arn), 0)
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.name
}
