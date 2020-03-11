# Azure Terraform

Provision a k8s cluster on Azure using Terraform

## Prerequisites

### Set up Terraform access to Azure

To enable Terraform to provision resources into Azure, create an Azure AD service principal. The service principal grants your Terraform scripts to provision resources in your Azure subscription.

Read on at [Quickstart: Install and configure Terraform to provision Azure resources](https://docs.microsoft.com/en-us/azure/terraform/terraform-install-configure)

If you have multiple Azure subscriptions, first query your account with az account list to get a list of subscription ID and tenant ID values:

```bash
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
# export ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
az account set --subscription="${ARM_SUBSCRIPTION_ID}"
az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}"
{
  "appId": "...",
  "displayName": "azure-cli-2020-03-09-14-05-33",
  "name": "http://azure-cli-2020-03-09-14-05-33",
  "password": "...",
  "tenant": "..."
}
# export ARM_CLIENT_ID=<appId>, ARM_CLIENT_SECRET=<password>
# export TF_VAR_arm_client_id=${ARM_CLIENT_ID}, TF_VAR_arm_client_secret=${ARM_CLIENT_SECRET}
```

**NOTE:** As of now, due to [terraform-provider-azurerm/issues/5275](https://github.com/terraform-providers/terraform-provider-azurerm/issues/5275#issuecomment-570284922) we need `Owner` rather `Contributor` until
`--attach-acr` is possible.

### Create Storage Account

Terraform state is used to reconcile deployed resources with Terraform configurations. State allows Terraform to know what Azure resources to add, update, or delete. By default, Terraform state is stored locally when you run the terraform apply command. This configuration isn't ideal for the following reasons:

- Local state doesn't work well in a team or collaborative environment.
- Terraform state can include sensitive information.
- Storing state locally increases the chance of inadvertent deletion.

Terraform supports the persisting of state in remote storage. One such supported back end is Azure Storage. This document shows how to configure and use Azure Storage for this purpose.

Before you use Azure Storage as a back end, you must create a storage account. The storage account can be created with the Azure portal, PowerShell, the Azure CLI, or Terraform itself. Use the following sample to configure the storage account with the Azure CLI.

Read on at [Configure storage account](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend#configure-storage-account)

```bash
#!/bin/bash
TF_VAR_prefix=hello-aks-seabhel
RESOURCE_GROUP_NAME=hello-aks-infrastructure-rg
# !length: 3-24, lowercase+digits only!
STORAGE_ACCOUNT_NAME=helloakstfbackend
CONTAINER_NAME=${TF_VAR_PREFIX}

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ARM_ACCESS_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ARM_ACCESS_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ARM_ACCESS_KEY"
```

Next configure your backend, e.g. using `terraform init -backend-config="KEY=VALUE"` or in `main.tf`

```terraform
terraform {
  # Terraform backend state, cf.:
  # - https://www.terraform.io/docs/backends/types/azurerm.html
  # - https://docs.microsoft.com/en-us/azure/terraform/terraform-backend
  backend "azurerm" {
    resource_group_name  = "<RESOURCE_GROUP_NAME=hello-aks-infrastructure-rg>"
    storage_account_name = "<STORAGE_ACCOUNT_NAME=helloakstfbackend>"
    #container_name       = ... # terraform init -backend-config="container_name=$(TF_VAR_prefix)"
    key = "terraform.tfstate"
    # access_key          = ARM_ACCESS_KEY (leave private)
  }
}
```

## Usage

After you configured Terraform to work with Azure you can now manage infrastructure

```bash
terraform init -backend-config="container_name=${TF_VAR_prefix}"
terraform plan -out current.tfplan
terraform apply current.tfplan
#terraform destroy
```

Typical timings

- Resource Group: create: ~2s, destroy ~1m
- ACR: create ~9s, destroy ~3s
- AKS: create ~10m, destroy ~6m
- AKS DevSpaces: create ~2m, destroy ~2m

## References

- [Install and configure Terraform to provision Azure resources](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

### Using multiple node pools

- [Create and manage multiple node pools for a cluster in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools)
- [azurerm_kubernetes_cluster_node_pool](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html) (TerraForm)

### AKS Storage Practices

- [Best practices for storage and backups in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-storage)
