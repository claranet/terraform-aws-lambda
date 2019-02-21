variable "function_name" {
  description = "A unique name for your Lambda function (and related IAM resources)"
  type        = "string"
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = "string"
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda function can use at runtime"
  type        = "string"
  default     = 128
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this Lambda function"
  type        = "string"
  default     = 0
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = "string"
}

variable "timeout" {
  description = "The amount of time your Lambda function had to run in seconds"
  type        = "string"
  default     = 10
}

variable "source_path" {
  description = "The source file or directory containing your Lambda source code. Ignored when `source_from_s3` = `true`"
  type        = "string"
  default     = ""
}

variable "build_command" {
  description = "The command that creates the Lambda package zip file"
  type        = "string"
  default     = "python build.py '$filename' '$runtime' '$source'"
}

variable "build_paths" {
  description = "The files or directories used by the build command, to trigger new Lambda package builds whenever build scripts change"
  type        = "list"
  default     = ["build.py"]
}

variable "description" {
  description = "Description of what your Lambda function does"
  type        = "string"
  default     = "Managed by Terraform"
}

variable "environment" {
  description = "Environment configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "dead_letter_config" {
  description = "Dead letter configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "attach_dead_letter_config" {
  description = "Set this to true if using the dead_letter_config variable"
  type        = "string"
  default     = false
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "attach_vpc_config" {
  description = "Set this to true if using the vpc_config variable"
  type        = "string"
  default     = false
}

variable "source_from_s3" {
  description = "Set this to true if fetching the Lambda source code from S3."
  type        = "string"
  default     = false
}

variable "s3_bucket" {
    description = "The S3 bucket location containing the function's deployment package. Required when `source_from_s3` = `true`. This bucket must reside in the same AWS region where you are creating the Lambda function."
    type        = "string"
    default     = ""
}

variable "s3_key" {
    description = "The S3 key of an object containing the function's deployment package. Required when `source_from_s3` = `true`"
    type        = "string"
    default     = ""
}

variable "tags" {
  description = "A mapping of tags"
  type        = "map"
  default     = {}
}

variable "policy" {
  description = "An addional policy to attach to the Lambda function"
  type        = "string"
  default     = ""
}

variable "attach_policy" {
  description = "Set this to true if using the policy variable"
  type        = "string"
  default     = false
}

variable "enable_cloudwatch_logs" {
  description = "Set this to false to disable logging your Lambda output to CloudWatch Logs"
  type        = "string"
  default     = true
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = "string"
  default     = false
}

variable "lambda_at_edge" {
  description = "Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function"
  type        = "string"
  default     = false
}

locals {
  publish = "${var.lambda_at_edge ? true : var.publish}"
  timeout = "${var.lambda_at_edge ? min(var.timeout, 5) : var.timeout}"
}
