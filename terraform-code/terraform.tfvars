# resource group credentials
resource_group_name = "khushi_rg"
location            = "EastUS"

# resources credentials
vnet_name           = "aks-vnet"
subnet_name         = "aks-subnet"
pip_name            = "aks-pip"
nsg_name            = "aks-nsg"
nic_name            = "aks-nic"
storageaccount_name = "kgsa11022024"
vm_name             = "khushi-vm"
cluster_name        = "khushi-aks"
system_node_count   = 2
acr_name            = "kgacr11022024"

# login credentials
vm_username = "azureuser"
vm_password = "Password@1234"
