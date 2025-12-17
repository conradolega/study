data "aws_s3_bucket" "blog" {
  bucket = "www.conradolega.xyz"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_actions_assume_role_for_blog" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
 
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn ]
    }    

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:conradolega/blog:environment:production"]
    }
  }  
}

resource "aws_iam_role" "blog" {
  name               = "blog"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_for_blog.json
}

data "aws_iam_policy_document" "publish_blog_to_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      data.aws_s3_bucket.blog.arn,
      "${data.aws_s3_bucket.blog.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "publish_blog_to_s3" {
  name   = "publish_blog_to_s3"
  policy = data.aws_iam_policy_document.publish_blog_to_s3.json
}

resource "aws_iam_role_policy_attachment" "publish_blog_to_s3" {
  role       = aws_iam_role.blog.name
  policy_arn = aws_iam_policy.publish_blog_to_s3.arn
}
