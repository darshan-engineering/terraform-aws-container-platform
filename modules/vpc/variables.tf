variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g. '10.0.0.0/16')"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to deploy subnets into"
}
