# tfsec:ignore:aws-s3-enable-bucket-encryption
resource "aws_s3_bucket" "static-site" {
  bucket = var.domain-name
  acl    = "public-read" #tfsec:ignore:aws-s3-no-public-access-with-acl

  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects",
        Effect    = "Allow",
        Principal = { AWS = "*" },
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${var.domain-name}/*"
      }
    ]
  })

  # N.B. We explicitly DO NOT use KMS encryption for objects in _static site_ S3
  # buckets because doing so can render Cloudfront unable to read them!
  #
  # Static sites should be reserved for serving non-sensitive content!

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  # logging {
  #   target_bucket = var.logging-bucket.id
  #   target_prefix = join("/", [var.name, "s3"])
  # }
}

resource "aws_s3_bucket_public_access_block" "static-site" {
  bucket = aws_s3_bucket.static-site.id

  # N.B. We _want_ public access to a static-site bucket!  The primary consumer
  # will be CloudFront, but having CloudFront access S3 in REST mode means we
  # can't do custom error handling, and showing index pages when given directory
  # paths.
  block_public_acls       = false #tfsec:ignore:aws-s3-block-public-acls
  block_public_policy     = false #tfsec:ignore:aws-s3-block-public-policy
  restrict_public_buckets = false #tfsec:ignore:aws-s3-no-public-buckets
  ignore_public_acls      = false #tfsec:ignore:aws-s3-ignore-public-acls
}
