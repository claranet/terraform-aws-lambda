# Create the role.

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

# Attach a policy for logs.

data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*",
    ]
  }
}

resource "aws_iam_policy" "logs" {
  name   = "${var.function_name}-logs"
  policy = "${data.aws_iam_policy_document.logs.json}"
}

resource "aws_iam_policy_attachment" "logs" {
  name       = "${var.function_name}-logs"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.logs.arn}"
}

# Attach an additional policy required for the dead letter config.

data "aws_iam_policy_document" "dead_letter" {
  count = "${var.attach_dead_letter_config ? 1 : 0}"

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]

    resources = [
      "${lookup(var.dead_letter_config, "target_arn", "")}",
    ]
  }
}

resource "aws_iam_policy" "dead_letter" {
  count = "${var.attach_dead_letter_config ? 1 : 0}"

  name   = "${var.function_name}-dl"
  policy = "${data.aws_iam_policy_document.dead_letter.json}"
}

resource "aws_iam_policy_attachment" "dead_letter" {
  count = "${var.attach_dead_letter_config ? 1 : 0}"

  name       = "${var.function_name}-dl"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.dead_letter.arn}"
}

# Attach an additional policy required for the VPC config

data "aws_iam_policy_document" "network" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "network" {
  count = "${var.attach_vpc_config ? 1 : 0}"

  name   = "${var.function_name}-network"
  policy = "${data.aws_iam_policy_document.network.json}"
}

resource "aws_iam_policy_attachment" "network" {
  count = "${var.attach_vpc_config ? 1 : 0}"

  name       = "${var.function_name}-network"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.network.arn}"
}

# Attach an additional policy if provided.

resource "aws_iam_policy" "additional" {
  count = "${var.attach_policy ? 1 : 0}"

  name   = "${var.function_name}"
  policy = "${var.policy}"
}

resource "aws_iam_policy_attachment" "additional" {
  count = "${var.attach_policy ? 1 : 0}"

  name       = "${var.function_name}"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.additional.arn}"
}
