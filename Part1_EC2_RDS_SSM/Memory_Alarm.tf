resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name  = "HighMemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "2"
  metric_name = "mem_used_percent"
  namespace = "CWAgent"
  period = "300"
  statistic = "Average"
  threshold = "80"
  alarm_description = "Alarm when Memory usage exceeds 80%"
  alarm_actions = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = "i-0b8398f496ca71426"
  }
}
