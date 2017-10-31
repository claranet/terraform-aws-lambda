output "function_arn" {
  value = "${element(concat(aws_lambda_function.lambda_with_vpc.*.arn, aws_lambda_function.lambda_without_vpc.*.arn), 0)}"
}

output "function_name" {
  value = "${element(concat(aws_lambda_function.lambda_with_vpc.*.function_name, aws_lambda_function.lambda_without_vpc.*.function_name), 0)}"
}

output "role_arn" {
  value = "${aws_iam_role.lambda.arn}"
}

output "role_name" {
  value = "${aws_iam_role.lambda.name}"
}
