module "lambda_email_fetcher" {
  source = "../lambda"
  function_name = "email-fetcher"
  source_file   = "./code-files/lambda/email_fetcher.py"
  container_based = false
}

resource "aws_cloudwatch_event_rule" "every_30_min" {
  name                = "every-30-min"
  schedule_expression = "rate(30 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_scheduler" {
  rule      = aws_cloudwatch_event_rule.every_30_min.name
  target_id = "lambda_scheduler"
  arn       = module.lambda_email_fetcher.lambda_arn 
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = "email-fetcher"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_30_min.arn
}
