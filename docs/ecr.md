# ECR — Elastic Container Registry

This module provisions a private ECR repository using [`terraform-aws-modules/ecr/aws`](https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest). It handles image storage, access control, tag mutability, lifecycle cleanup, and vulnerability scanning.

---

## Accepted Image Types

ECR is a generic OCI-compatible registry. It accepts:

- **Docker images** — standard `docker build` / `docker push` workflow
- **OCI images** — built with tools like `buildah` or `podman`
- **Multi-arch manifests** — manifest lists targeting `linux/amd64`, `linux/arm64`, etc.

Images are referenced by their full URI:

```
<account_id>.dkr.ecr.<region>.amazonaws.com/<repo_name>:<tag>
```

---

## Tag Mutability

The repository is configured with `IMMUTABLE_WITH_EXCLUSION` — a middle ground between fully immutable and fully mutable:

- **By default**, all tags are immutable. Once an image is pushed with a tag like `v1.0.0`, that tag cannot be overwritten. This prevents accidental overwrites in production.
- **Excluded tags** (allowed to be overwritten) are defined via wildcard filters:

```hcl
repository_image_tag_mutability_exclusion_filter = [
  { filter = "latest*", filter_type = "WILDCARD" },
  { filter = "dev-*",   filter_type = "WILDCARD" },
  { filter = "qa-*",    filter_type = "WILDCARD" },
]
```

This means `latest`, `dev-build-123`, `qa-rc1` can be re-pushed freely, while versioned tags like `v2.1.0` are locked.

---

## Lifecycle Policy

Lifecycle rules run automatically to keep the repository clean and control storage costs.

### Rule 1 — Expire untagged images after 7 days (Priority 1)

```json
{
  "rulePriority": 1,
  "description": "Clean up untagged/orphaned images after 7 days",
  "selection": {
    "tagStatus": "untagged",
    "countType": "sinceImagePushed",
    "countUnit": "days",
    "countNumber": 7
  },
  "action": { "type": "expire" }
}
```

Untagged images are typically leftover layers from a `latest` re-push (the old image loses its tag but stays in the registry). This rule cleans them up after 7 days.

### Rule 2 — Keep only the last 10 images (Priority 2)

```json
{
  "rulePriority": 2,
  "selection": {
    "tagStatus": "any",
    "countType": "imageCountMoreThan",
    "countNumber": 10
  },
  "action": { "type": "expire" }
}
```

Applies to all images regardless of tag status. When the repo exceeds 10 images, the oldest ones are expired automatically. Adjust `countNumber` to retain more history.

> Rules are evaluated in priority order — lower number = evaluated first.

---

## Image Scanning

Enhanced scanning is enabled via Amazon Inspector, providing CVE detection across OS packages and application dependencies.

### Scan on push — all repositories matching `sample-app*`

```hcl
{
  scan_frequency = "SCAN_ON_PUSH"
  filter = [{ filter = "sample-app*", filter_type = "WILDCARD" }]
}
```

Every image pushed to the repository is scanned immediately.

### Continuous scanning — repositories matching `sample-app-prod*`

```hcl
{
  scan_frequency = "CONTINUOUS_SCAN"
  filter = [{ filter = "sample-app-prod*", filter_type = "WILDCARD" }]
}
```

Production repositories are re-scanned periodically even after the initial push, catching newly disclosed CVEs in already-deployed images.

Scan results are visible in the ECR console under **Repositories → Images → Vulnerabilities**, and can trigger alerts via Amazon Inspector findings in Security Hub.

---

## Access Control

```hcl
repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
```

Only the IAM identity running Terraform (the caller) is granted read/write access to the repository. ECS tasks pull images using the **task execution role** (`AmazonECSTaskExecutionRolePolicy`), which grants ECR pull permissions separately — see [`ecs.md`](./ecs.md).

---

## Force Delete

```hcl
repository_force_delete = true
```

Allows `terraform destroy` to delete the repository even if it still contains images. Set to `false` in production to prevent accidental data loss.
