#--------------------------------------------------------------------------
terraform {
  # Terraform backend state, cf.:
  # - https://www.terraform.io/docs/backends/types/azurerm.html
  # - https://docs.microsoft.com/en-us/azure/terraform/terraform-backend
  backend "azurerm" {
    resource_group_name  = "hello-aks-infrastructure-rg"
    storage_account_name = "helloakstfbackend"
    #container_name       = ... # terraform init -backend-config="container_name=$(TF_VAR_prefix)"
    key = "terraform.tfstate"
    # access_key          = ARM_ACCESS_KEY (leave private)
  }
}

# - https://www.terraform.io/docs/providers/azurerm/index.html
# - https://github.com/terraform-providers/terraform-provider-azurerm
# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  # to upgrade, 1) comment out, 2) run `terraform init --upgrade` and 3) re-pin with the new version
  version = "=2.0.0"
  # workaround, cf.: https://github.com/terraform-providers/terraform-provider-azurerm/issues/5893#issuecomment-593335556
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # http://terraform.io/docs/providers/azurerm/index.html
  # subscription_id = ARM_SUBSCRIPTION_ID
  # tenant_id       = ARM_TENANT_ID
  # client_id       = ARM_CLIENT_ID
  # client_secret   = ARM_CLIENT_SECRET
}

# - https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks
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
  admin_enabled       = true # TODO: needed?
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
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name = "default"
    #node_count = 1
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
  }

  service_principal {
    client_id     = var.arm_client_id
    client_secret = var.arm_client_secret
  }

  tags = {
    Environment = var.environment
  }

  addon_profile {
    # TODO: testing only, not for production --> ingress
    http_application_routing {
      enabled = true
    }
    # TODO: no access to dashboard,  pod missing `kubectl get pods -n kube-system`
    kube_dashboard {
      enabled = true
    }
    # TODO: Add monitoring, cf.: https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-enable-existing-clusters#enable-using-terraform
    # oms_agent {
    #   enabled                    = true
    #   log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
    # }
  }
}

#--------------------------------------------------------------------------
# NOTE!!! Keep in mind that in order to create this role assignment you need
#  to have `owner` permissions or the `User Access Administrator` role for the subscription (afair)
# or at least for the ACR in advance.
# HACK: For the time being, we can create an `Owner` spn instead of only `Contributor`.
# Azure DevOps creates many SPN all with `Owner` roles for the subscription under the hood.
# --------
# Allow k8s to pull from ACR
# Assign AcrPull role to service principal
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/5275#issuecomment-579182890
resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = var.arm_client_id
  skip_service_principal_aad_check = true
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
  count = var.k8s_enable_devspaces ? 1 : 0

  name                = "acctestdsc1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "S1"

  #host_suffix                              = "suffix"
  target_container_host_resource_id        = azurerm_kubernetes_cluster.aks.id
  target_container_host_credentials_base64 = base64encode(azurerm_kubernetes_cluster.aks.kube_config_raw)

  tags = {
    environment = var.environment
  }
}
