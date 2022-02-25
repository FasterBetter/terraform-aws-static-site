variable "name" {
  type        = string
  description = "The name of this component.  E.G. 'www'."
}

variable "domain-name" {
  type        = string
  description = "The primary domain name of this component.  If there's multiple names, you probably want the one without 'www.' at the start."
}

variable "domain-alternatives" {
  type        = list(string)
  description = "Any domain aliases that the SSL certificate and CloudFront distribution should allow."
  default     = []
}

variable "zone" {
  description = "The Route53 zone in which to create the DNS records."
}

# TODO: Implement me!
# variable "logging-bucket" {
#   description = "The S3 bucket to which logs will be sent."
# }

variable "min-ttl" {
  type        = number
  description = "The minimum TTL for objects."
}

variable "default-ttl" {
  type        = number
  description = "The default TTL for objects."
}

variable "max-ttl" {
  type        = number
  description = "The maximum TTL for objects."
}

variable "lambdas" {
  type        = map(any)
  description = "Any lambda associations for the CloudFront distribution."
  default     = {}
}
