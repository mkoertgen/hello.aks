# Azure Terraform

Provision a k8s cluster on Azure using Terraform

## Prerequisites

```bash
$az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
$az account set --subscription="${SUBSCRIPTION_ID}"
$az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
{
  "appId": "...",
  "displayName": "azure-cli-2020-03-09-14-05-33",
  "name": "http://azure-cli-2020-03-09-14-05-33",
  "password": "...",
  "tenant": "
}
```

Note `appId/password` to use for `k8s_client_id/k8s_client_secret`.
To get the object Id of the service principal (`k8s_principal_id`) you will need to check Azure Portal UI at 

- [App registration](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)

## Usage

```console
terraform init
terraform plan [--out hello-aks.tfplan]
terraform apply [hello-aks.tfplan] [-auto-approve]
terraform show -no-color > hello-aks.tfstate
terraform destroy
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
