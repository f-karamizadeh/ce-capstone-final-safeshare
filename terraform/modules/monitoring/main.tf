# آلارم یک و دو: ای ال بی
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "safeshare-alb-5xx"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  statistic           = "Sum"
  alarm_actions       = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  alarm_name          = "safeshare-alb-latency"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  threshold           = 2
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]
}

# آلارم سه: ای اس جی سی پی یو
resource "aws_cloudwatch_metric_alarm" "asg_cpu" {
  alarm_name          = "safeshare-asg-cpu"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  evaluation_periods  = 2
  alarm_actions       = [var.sns_topic_arn]
}

# آلارم چهار: رم با کمک ایجنت
resource "aws_cloudwatch_metric_alarm" "mem" {
  alarm_name          = "safeshare-mem-high"
  namespace           = "CWAgent"
  metric_name         = "mem_used_percent"
  threshold           = 85
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]
}

# آلارم پنج و شش: بیزینس
resource "aws_cloudwatch_metric_alarm" "business_low_upload" {
  alarm_name          = "safeshare-low-upload"
  namespace           = "SafeShare/Business"
  metric_name         = "UploadCount"
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  statistic           = "Sum"
  period              = 86400
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "business_file_size" {
  alarm_name          = "safeshare-large-file"
  namespace           = "SafeShare/Business"
  metric_name         = "FileSize"
  threshold           = 104857600
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Maximum"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]
}

# داشبورد
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "SafeShare-Dashboard"
  dashboard_body = file("${path.module}/dashboard.json")
}