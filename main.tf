locals {
  static-site-origin-id = join("-", ["S3", var.domain-name])
}
