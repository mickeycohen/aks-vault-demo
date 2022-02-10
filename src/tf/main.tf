terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.48.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "mickeyk8srg" {
  name     = "mickeyk8s-RG"
  location = "northeurope"
}

resource "azurerm_kubernetes_cluster" "mickeyk8scluster" {
  name                = "mickeyk8scluster"
  location            = azurerm_resource_group.mickeyk8srg.location
  resource_group_name = azurerm_resource_group.mickeyk8srg.name
  dns_prefix          = "mickeyk8scluster"

  default_node_pool {
    name       = "default"
    node_count = "2"
    vm_size    = "standard_d2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}