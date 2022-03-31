resource "aws_glue_catalog_database" "database" {
  name = "test"
}

resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.database.name
  name          = "test"
  role          = aws_iam_role.glue_crawler.arn

  s3_target {
    path = "s3://${aws_s3_bucket.bucket.bucket}/data/"
  }
}
