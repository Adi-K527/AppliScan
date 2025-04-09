resource "aws_sns_topic" "appliscan_sns" {
  name        = "appliscan-emails-topic"
  fifo_topic  = true
}

resource "aws_sqs_queue" "model_queue" {
  for_each                    = var.models
  name                        = "${each.key}-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  for_each = var.models
  topic_arn = aws_sns_topic.appliscan_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.model_queue[each.key].arn
}

resource "aws_lambda_event_source_mapping" "job_status_trigger" {
  event_source_arn = aws_sqs_queue.model_queue["JobStatusModel"].arn
  function_name    = var.job_status_model_arn
}

resource "aws_lambda_event_source_mapping" "ner_trigger" {
  event_source_arn = aws_sqs_queue.model_queue["NerModel"].arn
  function_name    = var.ner_model_arn
}

resource "aws_lambda_function_event_invoke_config" "job_related_function_destination" {
  function_name = var.job_related_function_name

  destination_config {
    on_success {
      destination = aws_sns_topic.appliscan_sns.arn
    }
  }
}