data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_rds" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:DeleteObject", "s3:GetObject"]
        Resource = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "cleanup" {
  function_name    = "${var.project_name}-${var.environment}-cleanup"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  timeout          = 60
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      S3_BUCKET   = var.s3_bucket_name
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name = "${var.project_name}-cleanup-lambda"
  }
}

resource "aws_cloudwatch_event_rule" "daily" {
  name                = "${var.project_name}-${var.environment}-daily-cleanup"
  description         = "Run cleanup every day"
  schedule_expression = "rate(1 day)"

  tags = {
    Name = "${var.project_name}-cleanup-rule"
  }
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.daily.name
  target_id = "CleanupLambda"
  arn       = aws_lambda_function.cleanup.arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}
