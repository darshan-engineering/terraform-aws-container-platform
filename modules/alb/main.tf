module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0.0"

  name                       = "${var.tags.Project}-${var.tags.Environment}-alb"
  enable_deletion_protection = false # `true` in production

  vpc_id  = var.vpc_id
  subnets = var.public_subnets

  security_groups = var.alb_sg_id # Security group created in `sg` module

  # access_logs = {
  #   bucket = var.alb_log_bucket
  # }

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.acm_certificate_arn
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      forward = {
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
      name_prefix       = "app"
      protocol          = "HTTP"
      port              = var.container_port
      target_type       = "ip"  # When woking with ECS
      create_attachment = false # There's nothing to attach here in this definition. The attachment happens in the ASG modul

      health_check = {
        enabled             = true
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = var.tags
}
