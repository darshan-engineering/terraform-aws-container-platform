variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "ecr_repository_name" {
  type        = string
  description = "The primary base name of the Amazon ECR repository. Used dynamically to set up scanning filter boundaries."

  validation {
    condition     = can(regex("^[a-z0-9-_]+$", var.ecr_repository_name))
    error_message = "The ecr_repository_name variable must contain only lowercase alphanumeric characters, hyphens, or underscores."
  }
}
