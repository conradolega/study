resource "aws_iam_role" "kinesis_firehose" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "kinesis_firehose" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]

    resources = [
      aws_kinesis_stream.test.arn
    ]
  }
}

resource "aws_iam_policy" "kinesis_firehose" {
  policy = data.aws_iam_policy_document.kinesis_firehose.json
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose" {
  role       = aws_iam_role.kinesis_firehose.name
  policy_arn = aws_iam_policy.kinesis_firehose.arn
}

resource "aws_iam_role" "kinesis_analytics" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "kinesis_analytics" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]

    resources = [
      aws_kinesis_stream.test.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "firehose:DescribeDeliveryStream",
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.test.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:logs:*"
    ]
  }
}

resource "aws_iam_policy" "kinesis_analytics" {
  policy = data.aws_iam_policy_document.kinesis_analytics.json
}

resource "aws_iam_role_policy_attachment" "kinesis_analytics" {
  role       = aws_iam_role.kinesis_analytics.name
  policy_arn = aws_iam_policy.kinesis_analytics.arn
}

data "aws_iam_policy" "glue_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "glue_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

resource "aws_iam_role" "glue_crawler" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_service_role" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = data.aws_iam_policy.glue_service_role.arn
}

resource "aws_iam_role_policy_attachment" "glue_crawler_s3_full_access" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = data.aws_iam_policy.s3_full_access.arn
}
