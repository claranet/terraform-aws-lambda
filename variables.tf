variable "function_name" {
  description = "A unique name for your Lambda function (and related IAM resources)"
  type        = "string"
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = "string"
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = "string"
}

variable "timeout" {
  description = "The amount of time your Lambda function had to run in seconds"
  default     = 10
}

variable "source_path" {
  description = "The source file or directory containing your Lambda source code"
  default     = ""
}

variable "description" {
  description = "Description of what your Lambda function does"
  default     = "Managed by Terraform"
}

variable "environment" {
  description = "Environment configuration for the Lambda function"
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  default     = {}
}

variable "attach_vpc_config" {
  description = "Set this to true if using the vpc_config variable"
  default     = false
}

variable "tags" {
  description = "A mapping of tags"
  default     = {}
}

variable "policy" {
  description = "An addional policy to attach to the Lambda function"
  default     = ""
}

variable "attach_policy" {
  description = "Set this to true if using the policy variable"
  default     = false
}

variable "kms_key_arn" {
  description = "The ARN for the KMS encryption key to use to encrypt the Lambda function's parameters."
  default = ""
}
