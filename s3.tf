# tfsec:ignore:aws-s3-enable-bucket-encryption
resource "aws_s3_bucket" "static-site" {
  bucket = var.domain-name

  # N.B. We explicitly DO NOT use KMS encryption for objects in _static site_ S3
  # buckets because doing so can render Cloudfront unable to read them!
  #
  # Static sites should be reserved for serving non-sensitive content!

  # logging {
  #   target_bucket = var.logging-bucket.id
  #   target_prefix = join("/", [var.name, "s3"])
  # }
}

resource "aws_s3_bucket_website_configuration" "static-site" {
  bucket = aws_s3_bucket.static-site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "static-site" {
  bucket = aws_s3_bucket.static-site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "static-site" {
  bucket = aws_s3_bucket.static-site.id
  acl    = "public-read" #tfsec:ignore:aws-s3-no-public-access-with-acl
}

# TODO: Allow us to specify that the site will be fronted by CloudFlare, and use this:
# resource "aws_s3_bucket_policy" "static-site" {
#   # Details from: https://support.cloudflare.com/hc/en-us/articles/360037983412-Configuring-an-Amazon-Web-Services-static-site-to-use-Cloudflare
#   # Most recent IP range list: https://www.cloudflare.com/ips/
#   bucket = aws_s3_bucket.static-site.id
#   policy = jsonencode({
#     Version = "2008-10-17",
#     Statement = [
#       {
#         Sid       = "PublicReadForGetBucketObjects",
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "s3:GetObject",
#         Resource  = "arn:aws:s3:::${var.domain}/*",
#         Condition = {
#           IpAddress = {
#             "aws:SourceIp": [
#               "2400:cb00::/32",
#               "2606:4700::/32",
#               "2803:f800::/32",
#               "2405:b500::/32",
#               "2405:8100::/32",
#               "2a06:98c0::/29",
#               "2c0f:f248::/32",
#               "103.21.244.0/22",
#               "103.22.200.0/22",
#               "103.31.4.0/22",
#               "104.16.0.0/13",
#               "104.24.0.0/14",
#               "108.162.192.0/18",
#               "131.0.72.0/22",
#               "141.101.64.0/18",
#               "162.158.0.0/15",
#               "172.64.0.0/13",
#               "173.245.48.0/20",
#               "188.114.96.0/20",
#               "190.93.240.0/20",
#               "197.234.240.0/22",
#               "198.41.128.0/17",
#             ]
#           }
#         }
#       }
#     ]
#   })
# }

resource "aws_s3_bucket_policy" "static-site" {
  bucket = aws_s3_bucket.static-site.id
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
