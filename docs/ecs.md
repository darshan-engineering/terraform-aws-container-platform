# ECS — Elastic Container Service

This module provisions an ECS cluster and a Fargate service using [`terraform-aws-modules/ecs/aws`](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest) (v7). It covers the cluster, task definition, service, IAM roles, ALB integration, and auto-scaling.

---

## Cluster & Capacity Providers

```hcl
cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

default_capacity_provider_strategy = {
  FARGATE = { weight = 100 }
}
```

The cluster supports both `FARGATE` (on-demand) and `FARGATE_SPOT` (interruptible, ~70% cheaper). The default strategy sends 100% of tasks to on-demand Fargate. To split traffic and reduce cost, you can adjust weights:

```hcl
FARGATE      = { weight = 2 }   # 2 out of 3 tasks on-demand
FARGATE_SPOT = { weight = 1 }   # 1 out of 3 on spot
```

---

## IAM Roles — Automatically Created

The module automatically creates two IAM roles. You do not need to define them manually.

### Task Execution Role

**Name:** `<cluster-name>-cluster-exec` (managed by the module)  
**Attached policy:** `AmazonECSTaskExecutionRolePolicy`

This role is used by the **ECS agent** (not your application code) to:
- Pull the container image from ECR
- Write logs to CloudWatch Logs
- Fetch secrets from Secrets Manager or SSM Parameter Store (if configured)

The ARN is exposed as an output:

```hcl
output "task_execution_role_arn" {
  value = module.ecs.task_exec_iam_role_arn
}
```

### Task Role

A separate task role is also created for permissions **your application code** needs at runtime (e.g. accessing S3, DynamoDB, SQS). It starts with no policies attached — add policies to it as your application requires.

---

## Task Definition

```hcl
container_definitions = {
  app = {
    cpu    = var.cpu       # 256 vCPU units
    memory = var.memory    # 512 MiB

    image     = var.container_image   # ECR image URI
    essential = true

    portMappings = [
      {
        name          = "app"
        containerPort = var.container_port   # 80
        protocol      = "tcp"
      }
    ]

    enable_cloudwatch_logging = true
    readonlyRootFilesystem    = false
  }
}
```

Key points:
- **`essential = true`** — if this container exits, the entire task is stopped and replaced.
- **`portMappings`** uses camelCase keys (`containerPort`, not `container_port`) because the ECS module passes these directly to the AWS task definition JSON spec.
- **`enable_cloudwatch_logging = true`** — the module automatically creates a CloudWatch log group and configures the `awslogs` driver. No manual log configuration needed.
- **CPU/memory** are set at both the task level and container level. For a single-container task they should match.

### Valid Fargate CPU / Memory combinations

| CPU (units) | Memory options (MiB) |
|---|---|
| 256 | 512, 1024, 2048 |
| 512 | 1024 – 4096 (in 1024 increments) |
| 1024 | 2048 – 8192 (in 1024 increments) |
| 2048 | 4096 – 16384 (in 1024 increments) |
| 4096 | 8192 – 30720 (in 1024 increments) |

---

## How ECS Tasks Connect to the ALB

This is the most important wiring to understand. There are three components involved:

### 1. Target Group — `target_type = "ip"`

```hcl
# modules/alb/main.tf
target_groups = {
  app = {
    target_type       = "ip"
    create_attachment = false
    ...
  }
}
```

ALB target groups can register targets as EC2 instances (`instance`) or as IPs (`ip`). Fargate tasks **must** use `ip` because they have no EC2 instance backing them — each task gets its own ENI and private IP address directly in the subnet.

`create_attachment = false` tells the ALB module not to try attaching anything to the target group itself. The ECS service handles registration.

### 2. ECS Service — `load_balancer` block

```hcl
# modules/ecs/main.tf
load_balancer = {
  service = {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = var.container_port
  }
}
```

This tells ECS: whenever a task starts, automatically register its **container IP + port** with the target group. When a task stops or is replaced, ECS deregisters it. You never manually manage target group membership.

### 3. Health Check Grace Period

```hcl
health_check_grace_period_seconds = 60
```

When a new task starts, the ALB begins health checking it immediately. Without a grace period, ECS may see the task as unhealthy before the application has finished starting, and kill it in a loop. 60 seconds gives the container time to initialize before health checks are evaluated.

### End-to-end flow

```
ALB (port 443)
  └─► Target Group (type: ip)
        └─► Task ENI IP : containerPort (registered automatically by ECS on task start)
              └─► Container (app, port 80)
```

---

## Networking

```hcl
subnet_ids       = var.private_subnets
assign_public_ip = false
security_group_ids = [var.ecs_security_group_id]
```

Tasks run in **private subnets** with no public IP. Inbound traffic only arrives through the ALB. The ECS security group allows inbound on `container_port` only from the ALB security group — not from the internet directly.

Outbound internet access (for ECR image pulls, CloudWatch, etc.) is routed through the **NAT Gateway** provisioned by the VPC module.

---

## Auto-scaling

Auto-scaling is managed by the module via Application Auto Scaling. Two target tracking policies are configured:

```hcl
autoscaling_min_capacity = var.autoscaling_min_capacity   # 1
autoscaling_max_capacity = var.autoscaling_max_capacity   # 4
```

| Policy | Metric | Target |
|---|---|---|
| `cpu` | `ECSServiceAverageCPUUtilization` | 70% |
| `memory` | `ECSServiceAverageMemoryUtilization` | 80% |

Target tracking automatically adds tasks when the metric exceeds the target and removes them when it drops back down. Scale-in is conservative by default — AWS adds a cooldown to prevent flapping.

---

## ECS Exec

```hcl
enable_execute_command = true
```

Enables [ECS Exec](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html), which lets you open an interactive shell into a running container without SSH or a bastion host:

```bash
aws ecs execute-command \
  --cluster <cluster-name> \
  --task <task-id> \
  --container app \
  --interactive \
  --command "/bin/sh"
```

Requires the SSM agent to be present in the container image (included in most base images) and the task role to have `ssmmessages` permissions, which the module adds automatically when `enable_execute_command = true`.
