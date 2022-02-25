data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "static_site_deployer" {
  name = join("-", [var.name, "deployer"])

  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource "aws_iam_policy" "static-site-deployer" {
  name        = join("-", [var.name, "deployer"])
  description = join("", ["Policy allowing user to deploy to ", var.name])

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "OperationsOnBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          join("/", [aws_s3_bucket.static-site.arn, "*"]),
          aws_s3_bucket.static-site.arn
        ]
      },
      {
        "Sid" : "ShowBuckets",
        "Effect" : "Allow",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : "*"
      }
    ]
  })
}
