# Example remote state backend. Create the bucket according to your
# organization's naming/security standard before enabling this.
terraform {
  backend "s3" {
    bucket       = "AusPost-terraform-state-bucket"
    key          = "auspost/devsecops/eks.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
