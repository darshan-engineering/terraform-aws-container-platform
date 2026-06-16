terraform {
  backend "s3" {
    bucket       = "tfstate-qtiod7"
    key          = "dev/terraform.tfstate" # Dev Env
    # key        = "prod/terraform.tfstate" # Prod Env
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
