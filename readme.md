# ASKEM EKS Terraform

## Требования
- Terraform >= 1.5
- AWS CLI
- kubectl

## Запуск

```bash
export AWS_REGION=us-east-1
export TF_VAR_grafana_admin_password="YourStrongPassword!"

terraform init
terraform plan
terraform apply