resource "aws_cloudwatch_log_group" "logs" {
  name = "logs"
}

resource "aws_cloudwatch_log_stream" "kinesis_analytics" {
  name           = "kinesis_analytics"
  log_group_name = aws_cloudwatch_log_group.logs.name
}
