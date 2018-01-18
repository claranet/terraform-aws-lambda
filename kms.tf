# Find the ARN of the default aws/lambda KMS key.
data "external" "default_lambda_kms_arn" {
  program = ["${path.module}/default_kms_key_arn.py"]
}
