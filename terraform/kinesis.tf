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

  inputs {
    name_prefix = "input"

    kinesis_stream {
      resource_arn = aws_kinesis_stream.test.arn
      role_arn     = aws_iam_role.kinesis_analytics.arn
    }

    schema {
      record_columns {
        mapping  = "$.id"
        name     = "id"
        sql_type = "INT"
      }

      record_columns {
        mapping  = "$.type"
        name     = "type"
        sql_type = "VARCHAR(8)"
      }

      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }
    }

    starting_position_configuration {
      starting_position = "NOW"
    }
  }

  outputs {
    name = "output"

    schema {
      record_format_type = "CSV"
    }

    kinesis_firehose {
      resource_arn = aws_kinesis_firehose_delivery_stream.test.arn
      role_arn     = aws_iam_role.kinesis_analytics.arn
    }
  }

  start_application = true
}

resource "aws_kinesisanalyticsv2_application" "test" {
  name = "test"
  runtime_environment = "FLINK-1_13"
  service_execution_role = aws_iam_role.kinesis_analytics.arn
}
