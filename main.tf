data "aws_region" "current" {}

locals {
  common_tags = {
    Customer    = var.cust
    Application = var.app
    Environment = var.env
  }
  google_mx_records = [
    "1 ASPMX.L.GOOGLE.COM.",
    "5 ALT1.ASPMX.L.GOOGLE.COM.",
    "5 ALT2.ASPMX.L.GOOGLE.COM.",
    "10 ALT3.ASPMX.L.GOOGLE.COM.",
    "10 ALT4.ASPMX.L.GOOGLE.COM."
  ]  
}

resource "aws_route53_record" "mx_records" {
  count   = length(local.google_mx_records)
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 300
  records = [local.google_mx_records[count.index]]
}

resource "aws_route53_record" "google_verification" {
  count   = var.enable_google_verification ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  records = [var.google_verification_value]
}

resource "aws_route53_record" "github_verification" {
  count   = var.enable_github_pages_verification ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  records = [var.github_verification_value]
}

resource "aws_route53_record" "wildcard_record" {
  count   = var.enable_wildcard_record ? 1 : 0
  zone_id = var.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.wildcard_target]
}

resource "aws_route53_record" "apex_record" {
  count   = var.enable_apex_record ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [var.apex_target]
}

resource "aws_route53_record" "www_record" {
  count   = var.enable_www_record ? 1 : 0
  zone_id = var.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.www_target]
}
