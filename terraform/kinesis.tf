resource "aws_kinesis_stream" "test" {
  name             = "test"
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kinesis_stream_consumer" "test" {
  name = "test"
  stream_arn = aws_kinesis_stream.test.arn
}

resource "aws_kinesis_firehose_delivery_stream" "test" {
  name        = "test"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose.arn
    bucket_arn = aws_s3_bucket.bucket.arn
    prefix     = "firehose/"
  }
}

resource "aws_kinesis_analytics_application" "sql" {
  name = "sql"
}

resource "aws_kinesisanalyticsv2_application" "test" {
  name = "test"
  runtime_environment = "FLINK-1_13"
  service_execution_role = aws_iam_role.kinesis_analytics.arn
}
