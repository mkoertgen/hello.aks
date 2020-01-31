# Azure Terraform

Provision a k8s cluster on Azure using Terraform

## Prerequisites

```console
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
az account set --subscription="${SUBSCRIPTION_ID}"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```

## Usage

```console
terraform init
terraform play --out example.plan
terraform apply example.plan
terraform destroy
```

## References

See

- [Install and configure Terraform to provision Azure resources](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)