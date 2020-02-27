output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = aws_lambda_function.lambda.invoke_arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = aws_lambda_function.lambda.qualified_arn
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the log group created for this Lambda if logging is enabled."
  value       = aws_cloudwatch_log_group.lambda[0].arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the log group created for this Lambda if logging is enabled."
  value       = aws_cloudwatch_log_group.lambda[0].name
}
