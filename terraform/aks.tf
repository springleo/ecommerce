terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

terraform {
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

# Public subnet (Frontend / Ingress)
resource "azurerm_subnet" "public" {
  name                 = "snet-public-frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Private subnet (Backend + DB workloads)
resource "azurerm_subnet" "private" {
  name                 = "snet-private-backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

# -----------------------------
# Network Security Groups
# -----------------------------
resource "azurerm_network_security_group" "public_nsg" {
  name                = "nsg-public"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "private_nsg" {
  name                = "nsg-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "public_assoc" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_assoc" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

# -----------------------------
# Azure Container Registry
# -----------------------------
resource "azurerm_container_registry" "acr" {
  name                = "ecommerceacrmmikkil"   # must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = {
    environment = "prod"
  }
}

# -----------------------------
# AKS → ACR Pull Permission
# -----------------------------
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# -----------------------------
# AKS Cluster
# -----------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "ecommerce-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ecommerceaks"

  # 🔐 Private API Server (Best Practice)
  # private_cluster_enabled = true

  identity {
    type = "SystemAssigned"
  }

  # Use Azure CNI for subnet-level control
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  # System Node Pool (critical components only)
  default_node_pool {
    name                 = "system"
    node_count           = 2
    vm_size              = "Standard_D2s_v3"
    vnet_subnet_id       = azurerm_subnet.private.id
    orchestrator_version = null

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
# User Node Pool (Workloads)
# Backend / Frontend scaling
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
    "workload" = "apps"
  }
}

