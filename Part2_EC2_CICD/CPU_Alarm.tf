resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = "i-0b8398f496ca71426"

  }
}
