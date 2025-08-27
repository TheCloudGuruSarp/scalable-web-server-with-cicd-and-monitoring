# ------------------------------------------------------------------------------
# Observability (CloudWatch Alarms and SNS)
# ------------------------------------------------------------------------------

# Create an SNS topic for sending alerts
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms-topic"

  tags = {
    Name = "${var.project_name}-alarms-topic"
  }
}

# Note for user: To receive email notifications, you would add a subscription resource like this.
# This requires manual confirmation from the email owner after `terraform apply`.
# resource "aws_sns_topic_subscription" "email_target" {
#   topic_arn = aws_sns_topic.alarms.arn
#   protocol  = "email"
#   endpoint  = "your-email@example.com" # Replace with your email address
# }

# CloudWatch Alarm for high CPU utilization on the backend ECS service
resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "${var.project_name}-backend-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300" # 5 minutes
  statistic           = "Average"
  threshold           = "70" # 70%

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }

  alarm_description = "This metric monitors the average CPU utilization of the backend ECS service."
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn] # Also notify when the alarm state returns to OK

  tags = {
    Name = "${var.project_name}-backend-cpu-alarm"
  }
}
