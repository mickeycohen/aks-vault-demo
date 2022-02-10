resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.mickeyk8scluster]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.mickeyk8scluster.kube_config_raw
}
