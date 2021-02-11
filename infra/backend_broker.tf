resource "aws_iam_role" "broker_access" {
  name = "${var.env_prefix}broker_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "broker_logs" {
  role       = aws_iam_role.broker_access.name
  policy_arn = aws_iam_policy.lambda_logs_access.arn
}


resource "aws_iam_policy" "broker_dynamo_access" {
  name        = "${var.env_prefix}broker_dynamo_access"
  description = "IAM policy for DynamoDB access to broker lambda"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [

        "${aws_dynamodb_table.queues.arn}",
        "${aws_dynamodb_table.queues.arn}/*",


        "${aws_dynamodb_table.messages.arn}",
        "${aws_dynamodb_table.messages.arn}/*",


        "${aws_dynamodb_table.codes.arn}",
        "${aws_dynamodb_table.codes.arn}/*",

            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "broker_dynamo_access" {
  role       = aws_iam_role.broker_access.name
  policy_arn = aws_iam_policy.broker_dynamo_access.arn
}


resource "aws_lambda_function" "broker" {
  filename         = "/tmp/broker.zip"
  function_name    = "${var.env_prefix}broker"
  role             = aws_iam_role.broker_access.arn
  handler          = "broker"
  source_code_hash = filebase64sha256("/tmp/broker.zip")
  runtime          = "go1.x"
  environment {
        variables = {
            queuesTable = var.queuesTable
            messagesTable = var.messagesTable
            codesTable = var.codesTable
        }
    }

}