variable "name" {
  description = "Name prefix for WAF resources (e.g. 'high-availability-infra-dev')"
  type        = string
}

# variable "waf_log_bucket_arn" {
#   description = "ARN of the S3 bucket for WAF logs (bucket name must start with 'aws-waf-logs-')"
#   type        = string
# }

variable "alb_arn" {
  description = "ARN of the ALB to associate with the Web ACL"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
