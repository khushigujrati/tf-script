output "aks_id" {
  value = azurerm_kubernetes_cluster.impl-cluster.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.impl-cluster.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.impl-cluster.node_resource_group
}

output "acr_id" {
  value = azurerm_container_registry.impl-acr.id
}

output "acr_login_server" {
  value = azurerm_container_registry.impl-acr.login_server
}

resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.impl-cluster]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.impl-cluster.kube_config_raw
}
