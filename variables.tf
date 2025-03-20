variable "cust" {
  type        = string
  description = "A unique identifier to differentiate this deployment."
}

variable "app" {
  type        = string
  description = "A unique identifier to differentiate this deployment."
}

variable "env" {
  type        = string
  description = "Environment name, such as 'dev', 'Test', or 'Production'"
}

variable "topic_name" {
  type        = string
  description = "The name of the SNS topic to be created."
}

variable "service_identifiers" {
  type        = list(string)
  description = "List of services allowed to publish to this SNS topic."
}

variable "domain_name" {
  description = "The domain name for the DNS records."
  type        = string
}

variable "zone_id" {
  description = "The Route 53 hosted zone ID."
  type        = string
}

variable "enable_google_verification" {
  description = "Whether to enable Google verification TXT record."
  type        = bool
  default     = false
}

variable "google_verification_value" {
  description = "The value for the Google verification TXT record."
  type        = string
  default     = ""
}

variable "enable_github_pages_verification" {
  description = "Whether to enable GitHub Pages verification TXT record."
  type        = bool
  default     = false
}

variable "github_verification_value" {
  description = "The value for the GitHub Pages verification TXT record."
  type        = string
  default     = ""
}

variable "enable_wildcard_record" {
  description = "Whether to enable a wildcard DNS record."
  type        = bool
  default     = false
}

variable "wildcard_target" {
  description = "The target for the wildcard DNS record (e.g., CloudFront distribution domain or IP address)."
  type        = string
  default     = ""
}

variable "enable_apex_record" {
  description = "Whether to enable an apex A record pointing to an IP address."
  type        = bool
  default     = false
}

variable "apex_target" {
  description = "The target IP address for the apex A record."
  type        = string
  default     = ""
}

variable "enable_www_record" {
  description = "Whether to enable a www A record pointing to an IP address."
  type        = bool
  default     = false
}

variable "www_target" {
  description = "The target IP address for the www A record."
  type        = string
  default     = ""
}
