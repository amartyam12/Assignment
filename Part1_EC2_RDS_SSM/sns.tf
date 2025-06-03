resource "aws_sns_topic" "alerts" {
  name = "ec2-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "amartyam12@example.com"
}
