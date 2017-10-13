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

variable "source_dir" {
  description = "The source directory containing your Lambda scripts (use this or source_file)"
  default     = ""
}

variable "source_file" {
  description = "The file path of your Lambda script  (use this or source_dir)"
  default     = ""
}

variable "description" {
  description = "Description of what your Lambda function does"
  default     = "Managed by Terraform"
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"

  # Add a dummy variable because it can't be empty.
  default = {
    PLACEHOLDER = "1"
  }
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
