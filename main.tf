# In Azure, all infrastructure elements such as virtual machines, storage, and our Kubernetes cluster need to be attached to a resource group.

# Create a resource group
resource "azurerm_resource_group" "impl-rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "dev"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "impl-vn" {
  name                = var.vnet_name
  location            = azurerm_resource_group.impl-rg.location
  resource_group_name = azurerm_resource_group.impl-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev"
  }
}

# Create a subnet
resource "azurerm_subnet" "impl-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.impl-rg.name
  virtual_network_name = azurerm_virtual_network.impl-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "impl-pip" {
  name                = var.pip_name
  resource_group_name = azurerm_resource_group.impl-rg.name
  location            = azurerm_resource_group.impl-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

# Create a network security group
resource "azurerm_network_security_group" "impl-nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.impl-rg.location
  resource_group_name = azurerm_resource_group.impl-rg.name

  security_rule {
    name                       = "aks-nsg-dev-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "dev"
  }
}

# Create a network security group and associate it with the subnet within the Virtual Network
resource "azurerm_subnet_network_security_group_association" "impl-sga" {
  subnet_id                 = azurerm_subnet.impl-subnet.id
  network_security_group_id = azurerm_network_security_group.impl-nsg.id
}

# Create a network interface and associate with public IP and NSG
resource "azurerm_network_interface" "impl-nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.impl-rg.location
  resource_group_name = azurerm_resource_group.impl-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.impl-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.impl-pip.id
  }

  tags = {
    environment = "dev"
  }
}

# Create a storage account
resource "azurerm_storage_account" "impl-sa" {
  name                     = var.storageaccount_name
  resource_group_name      = azurerm_resource_group.impl-rg.name
  location                 = azurerm_resource_group.impl-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "dev"
  }
}

# Create a storage account for boot diagnostics
resource "azurerm_storage_account" "impl-sa-bootdiag" {
  name                     = "bootdiag11022024"
  resource_group_name      = azurerm_resource_group.impl-rg.name
  location                 = azurerm_resource_group.impl-rg.location
  account_tier             = split("_", var.boot_diagnostics_sa_type)[0]
  account_replication_type = split("_", var.boot_diagnostics_sa_type)[1]
}

# Create a container registry
resource "azurerm_container_registry" "impl-acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.impl-rg.name
  location            = azurerm_resource_group.impl-rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    environment = "dev"
  }
}

# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "impl-cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.impl-rg.location
  resource_group_name = azurerm_resource_group.impl-rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.system_node_count
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  tags = {
    environment = "dev"
  }
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "impl-vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.impl-rg.location
  resource_group_name   = azurerm_resource_group.impl-rg.name
  network_interface_ids = [azurerm_network_interface.impl-nic.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "azureuser"

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.impl-sa-bootdiag.primary_blob_endpoint
  }

  tags = {
    environment = "dev"
  }
}
