output "bucket" {
  value = aws_s3_bucket.static-site
}

output "distribution" {
  value = aws_cloudfront_distribution.static-site
}

output "iam-policy" {
  value = aws_iam_policy.static-site-deployer
}
