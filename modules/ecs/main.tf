module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.0"

  cluster_name = "${var.name}-cluster"

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
    }
  }

  services = {
    app = {
      cpu    = var.cpu
      memory = var.memory

      desired_count                     = var.desired_count
      enable_execute_command            = var.enable_execute_command
      health_check_grace_period_seconds = 60

      subnet_ids       = var.private_subnets
      assign_public_ip = false

      security_group_ids = [var.ecs_security_group_id]

      container_definitions = {
        app = {
          cpu       = var.cpu
          memory    = var.memory
          essential = true
          image     = var.container_image

          portMappings = [
            {
              name          = "app"
              containerPort = var.container_port
              protocol      = "tcp"
            }
          ]

          enable_cloudwatch_logging = true
          readonlyRootFilesystem    = false
        }
      }

      enable_autoscaling       = true
      autoscaling_min_capacity = var.autoscaling_min_capacity
      autoscaling_max_capacity = var.autoscaling_max_capacity

      autoscaling_policies = {
        cpu = {
          policy_type = "TargetTrackingScaling"
          target_tracking_scaling_policy_configuration = {
            predefined_metric_specification = {
              predefined_metric_type = "ECSServiceAverageCPUUtilization"
            }
            target_value = 70
          }
        }
        memory = {
          policy_type = "TargetTrackingScaling"
          target_tracking_scaling_policy_configuration = {
            predefined_metric_specification = {
              predefined_metric_type = "ECSServiceAverageMemoryUtilization"
            }
            target_value = 80
          }
        }
      }

      load_balancer = {
        service = {
          target_group_arn = var.target_group_arn
          container_name   = "app"
          container_port   = var.container_port
        }
      }
    }
  }

  tags = var.tags
}
