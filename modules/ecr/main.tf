data "aws_caller_identity" "current" {}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                   = var.ecr_repository_name
  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]

  repository_force_delete = true # Allow deleting repository even if it contains images

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Clean up untagged/orphaned images after 7 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 7
        },
        action = { type = "expire" }
      },
      {
        rulePriority = 2,
        description  = "Keep last 10 images",
        selection = {
          tagStatus = "any", # Apply to all images. For versioned images, use "tagged"
          # tagPrefixList = ["v"],    # Images with version tags (v1.0, v2.0, etc.)
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire" # Delete older images automatically
        }
      }
    ]
  })

  # Sets default repository behavior to Immutable, but enables custom exclusion rules
  repository_image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  # Defines wildcard patterns for tags that are allowed to be overwritten (Mutable)
  repository_image_tag_mutability_exclusion_filter = [
    {
      filter      = "latest*"
      filter_type = "WILDCARD"
    },
    {
      filter      = "dev-*"
      filter_type = "WILDCARD"
    },
    {
      filter      = "qa-*"
      filter_type = "WILDCARD"
    }
  ]

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = true
  registry_scan_type                     = "ENHANCED"
  registry_scan_rules = [
    {
      # Scan development and auxiliary apps immediately upon pushing
      scan_frequency = "SCAN_ON_PUSH"
      # Matches all repositories belonging to the high-availability-infra namespace (e.g. high-availability-infra/*)
      filter = [
        {
          filter      = "${var.ecr_repository_name}*"
          filter_type = "WILDCARD"
        }
      ]
    },
    {
      # Continuously monitor main production-facing application repositories
      scan_frequency = "CONTINUOUS_SCAN"
      # Matches all production repositories (e.g. high-availability-infra-prod*)
      filter = [
        {
          filter      = "${var.ecr_repository_name}-prod*"
          filter_type = "WILDCARD"
        }
      ]
    }
  ]


  tags = var.tags
}
