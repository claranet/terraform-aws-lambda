terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "terraform-aws-lambda-scheduled-"
}

module "lambda" {
  source = "../../"

  function_name = "${random_id.name.hex}"
  description   = "Test cloudwatch rule trigger in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  attach_cloudwatch_rule_config = true

  cloudwatch_rule_config {
    name = "scheduled-run"
    # enabled = false
    description = "Test scheduled lambda run"
    schedule_expression = "cron(0 20 * * ? *)"
    input = "{\"key\": \"value\"}"
  }
}

output "cloudwatchrule_arn" {
  value = "${module.lambda.cloudwatch_rule_arn}"
}
