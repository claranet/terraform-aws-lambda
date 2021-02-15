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

output "filename" {
  description = "The filename of the Lambda function"
  value       = lookup(null_resource.archive.triggers, "filename")
}

output "version" {
  description = "The version of the Lambda function"
  value       = lookup(random_pet.published_version.keepers, "version")
}

output "version_id" {
  description = "The version_id of the Lambda function (required when passing the version)"
  value       = random_pet.published_version.id
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.name
}
