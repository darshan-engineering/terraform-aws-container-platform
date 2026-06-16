variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "ID of the VPC in which to create security groups"
  type        = string
}

variable "container_port" {
  description = "Port that the continer will listen on"
  type        = number
}
