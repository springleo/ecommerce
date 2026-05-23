terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "mmikkilsa"
    container_name       = "tfstate"
    key                  = "aks-ecommerce.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-ecommerce-aks"
  location = "centralindia"
}

# -----------------------------
# Virtual Network
# -----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ecommerce"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

# Public subnet (optional for future use)
resource "azurerm_subnet" "public" {
  name                 = "snet-public-frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Private subnet (AKS nodes live here)
resource "azurerm_subnet" "private" {
  name                 = "snet-private-backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

# -----------------------------
# Azure Container Registry
# -----------------------------
/** resource "azurerm_container_registry" "acr" {
  name                = "ecommerceacrmmikkil" # must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = {
    environment = "prod"
  }
} **/

# -----------------------------
# AKS Cluster
# -----------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "ecommerce-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ecommerceaks"

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.private.id

    upgrade_settings {
      max_surge = "33%"
    }
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "prod"
  }
}

# -----------------------------
# User Node Pool
# -----------------------------
resource "azurerm_kubernetes_cluster_node_pool" "apps" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2s_v3"
  node_count            = 2
  mode                  = "User"
  vnet_subnet_id        = azurerm_subnet.private.id

  enable_auto_scaling = true
  min_count           = 2
  max_count           = 5

  node_labels = {
    workload = "apps"
  }
}

# -----------------------------
# AKS → ACR Pull Permission
# -----------------------------
# resource "azurerm_role_assignment" "aks_acr_pull" {
#   principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr.id
#   skip_service_principal_aad_check = true
# }
