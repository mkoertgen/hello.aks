# k8s / aks
output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

#---- acr
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value = azurerm_container_registry.acr.admin_password
}
