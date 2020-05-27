provider "azurerm" {
  version = "=1.28"
}

variable "service_principal_client_id" {
  description = "The Client ID for the Service Principal"
}

variable "service_principal_client_secret" {
  description = "The Client Secret for the Service Principal"
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-exist"
  location = "japaneast"
}

data "azurerm_resource_group" "example" {
  name = "aks-csi"
}

output "id" {
  value = data.azurerm_resource_group.example.id
}

data "azurerm_subnet" "example" {
  name                 = "aks-subnet"
  virtual_network_name = "aks-vnet"
  resource_group_name  = azurerm_resource_group.example.name
}

output "subnet_id" {
  value = data.azurerm_subnet.example.id
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name       = "aks"
  location   = azurerm_resource_group.example.location
  dns_prefix = "aks"

  resource_group_name = "${azurerm_resource_group.rg.name}"
  kubernetes_version  = "1.15.10"

  agent_pool_profile {
    name           = "aks"
    count          = "1"
    vm_size        = "Standard_D1s_v3"
    os_type        = "Linux"
    vnet_subnet_id = subnet_id
  }

  service_principal {
    client_id     = "${var.service_principal_client_id}"
    client_secret = "${var.service_principal_client_secret}"
  }

  network_profile {
    network_plugin = "azure"
  }
}

# output "kube_config" {
#   value = "${azurerm_kubernetes_cluster.cluster.kube_config_raw}"
# }

