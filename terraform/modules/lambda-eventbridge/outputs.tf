output "lambda_name" {
  value = aws_lambda_function.cleanup.function_name
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.daily.name
}
