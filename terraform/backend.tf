# Example remote state backend. Create the bucket according to your
# organization's naming/security standard before enabling this.
terraform {
  backend "s3" {
    bucket       = "app-k8-deployment-terraform-state-bucket"
    key          = "app-k8-deployment/devsecops/eks.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
