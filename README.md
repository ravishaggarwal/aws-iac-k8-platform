# AWS / IaC — EKS Foundation

## Responsibility
This repository owns Terraform for the AWS infrastructure beneath the Kubernetes platform. Application releases must not require changing this repository.

## Resources
The reference Terraform provisions the VPC/subnets and connectivity, EKS and managed nodes, OIDC/IAM foundation, AWS Load Balancer Controller IAM policy/role, Route53 and ACM certificate foundation.

## Layout
```text
terraform/main.tf
terraform/variables.tf
terraform/outputs.tf
terraform/versions.tf
terraform/terraform.tfvars.example
terraform/backend.tf.example
terraform/aws-load-balancer-controller-policy.json
scripts/
```

## Provision
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Configure kubectl after creation:
```bash
aws eks update-kubeconfig --region ap-southeast-2 --name <cluster-name>
kubectl get nodes
```

## IAM
Use dedicated least-privilege IAM roles. The AWS Load Balancer Controller must not receive blanket administrator permissions. Application workloads requiring AWS APIs should use their own workload identity/role rather than node credentials.

## DNS/TLS
The target host is `myapp-k8-deployment.com.au`. Terraform establishes Route53/ACM prerequisites; the Platform repository's Ingress causes the controller to create the ALB. If DNS is registered elsewhere, delegate the appropriate Route53 nameservers/records according to your organisation's DNS model.

## State and production hardening
Use an encrypted remote Terraform backend with approved locking, strict bucket access and versioning. Review EKS endpoint exposure, KMS, CloudTrail/audit logging, security monitoring, tagging, node AMIs, backup/DR and organisation guardrails before production.

## Outputs consumed by Platform/CI-CD
Typical outputs include EKS cluster name/region, AWS Load Balancer Controller role ARN, hosted-zone/certificate information and any deployment-role identifiers required by Jenkins.
