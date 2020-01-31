# - https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks
# - https://www.terraform.io/docs/providers/azurerm/index.html
# - https://github.com/terraform-providers/terraform-provider-azurerm

# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.42.0"

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # http://terraform.io/docs/providers/azurerm/index.html

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."  
}

#--------------------------------------------------------------------------
# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

#--------------------------------------------------------------------------
# Create Azure Container Registry
# https://www.terraform.io/docs/providers/azurerm/r/container_registry.html
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.prefix, "-", "")}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
  #georeplication_locations = ["East US", "West Europe"]
}


#--------------------------------------------------------------------------
# Create Azure Kubernetes Cluster
# https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-aks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name = "default"
    #node_count = 1
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
  }

  service_principal {
    client_id     = var.kubernetes_client_id
    client_secret = var.kubernetes_client_secret
  }

  tags = {
    Environment = "Production"
  }
}

#--------------------------------------------------------------------------
# Allow k8s to pull from ACR
# Assign AcrPull role to service principal
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/5275#issuecomment-579182890
resource "azurerm_role_assignment" "acrpull_role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.kubernetes_client_id
  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks
  ]
}

#--------------------------------------------------------------------------
# (optional) Enable [Azure Dev spaces](https://docs.microsoft.com/bs-latn-ba/azure/dev-spaces/)
# - https://www.terraform.io/docs/providers/azurerm/r/devspace_controller.html
resource "azurerm_devspace_controller" "devspaces" {
  # Conditional trick, cf.: https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  count = var.enable_devspaces ? 1 : 0

  name                = "acctestdsc1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "S1"

  #host_suffix                              = "suffix"
  target_container_host_resource_id        = azurerm_kubernetes_cluster.aks.id
  target_container_host_credentials_base64 = base64encode(azurerm_kubernetes_cluster.aks.kube_config_raw)

  tags = {
    Environment = "Testing"
  }
}
