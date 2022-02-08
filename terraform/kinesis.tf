resource "aws_kinesis_stream" "test" {
  name             = "test"
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}
