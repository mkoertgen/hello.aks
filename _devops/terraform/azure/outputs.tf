# k8s / aks
output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "aks_client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "aks_client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "aks_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}

output "aks_host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "aks_basedomain" {
  value = azurerm_kubernetes_cluster.aks.addon_profile[0].http_application_routing[0].http_application_routing_zone_name
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
