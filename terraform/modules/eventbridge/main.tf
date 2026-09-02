resource "aws_cloudwatch_event_bus" "main" {
  name = "safeshare-bus"
}

resource "aws_cloudwatch_event_rule" "upload" {
  name           = "safeshare-upload-rule"
  event_bus_name = aws_cloudwatch_event_bus.main.name
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
  })
}

resource "aws_cloudwatch_event_rule" "download" {
  name           = "safeshare-download-rule"
  event_bus_name = aws_cloudwatch_event_bus.main.name
  event_pattern = jsonencode({
    source      = ["safeshare.app"]
    detail-type = ["File Downloaded"]
  })
}