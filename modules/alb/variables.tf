variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to attach the ALB to"
}

variable "public_subnets" {
  type        = list(string)
  description = "The public subnets to attach the ALB to"
}

variable "alb_sg_id" {
  type        = list(string)
  description = "The Security Group ID for ALB"
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "container_port" {
  description = "Port that the continer will listen on"
  type        = number
}

# variable "alb_log_bucket" {
#   type        = string
#   description = "S3 bucket for ALB logs"
# }
