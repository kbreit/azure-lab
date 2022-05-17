provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kbreit-vwan-rg" {
  name = var.azure_rg_name
  location = var.azure_rg_region

  tags = {
    owner = "Kevin Breit"
  }
}

resource "azurerm_virtual_wan" "vwan" {
  name = "kbreit-vwan"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location = azurerm_resource_group.kbreit-vwan-rg.location
}

resource "azurerm_virtual_hub" "vwan_hub" {
  name = "kbreit-vwan-hub"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location = azurerm_resource_group.kbreit-vwan-rg.location
  virtual_wan_id = azurerm_virtual_wan.vwan.id
  address_prefix = var.azure_vnet_lz_subnets[4]
}

resource "azurerm_virtual_hub_connection" "hub_app_connection" {
  name = "hub-app-connection"
  virtual_hub_id = azurerm_virtual_hub.vwan_hub.id
  remote_virtual_network_id = module.vnet_app.vnet_id
}

resource "azurerm_virtual_hub_connection" "hub_common_connection" {
  name = "hub-common-connection"
  virtual_hub_id = azurerm_virtual_hub.vwan_hub.id
  remote_virtual_network_id = module.vnet_common.vnet_id
}

module "vnet_default" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  address_space = var.azure_vnet_lz_address_spaces
  vnet_name = var.azure_vnet_lz_names
  subnet_prefixes = var.azure_vnet_lz_subnets
  subnet_names = var.azure_lz_subnet_names

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_app" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name =  azurerm_resource_group.kbreit-vwan-rg.name
  address_space = var.azure_vnet_app_address_spaces
  vnet_name = var.azure_vnet_app_names
  subnet_prefixes = var.azure_vnet_app_subnets
  subnet_names = var.azure_app_subnet_names

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_common" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name =  azurerm_resource_group.kbreit-vwan-rg.name
  address_space = var.azure_vnet_common_address_spaces
  vnet_name = var.azure_vnet_common_names
  subnet_prefixes = var.azure_vnet_common_subnets
  subnet_names = var.azure_common_subnet_names

  tags = {
    owner = "Kevin Breit"
  }
}

resource "azurerm_network_interface" "app_vnet_vm_intf" {
  name = "app-vm-intf"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location            = azurerm_resource_group.kbreit-vwan-rg.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_app.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app_vnet_vm" {
  name = "kbreit-app-vnet-vm"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location            = azurerm_resource_group.kbreit-vwan-rg.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.app_vnet_vm_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_distribution
    version   = "latest"
  }
}

resource "azurerm_network_interface" "common_vnet_vm_intf" {
  name = "common-vm-intf"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location            = azurerm_resource_group.kbreit-vwan-rg.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_common.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "common_vnet_vm" {
  name = "kbreit-common-vnet-vm"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location            = azurerm_resource_group.kbreit-vwan-rg.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.common_vnet_vm_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_distribution
    version   = "latest"
  }
}

resource "azurerm_public_ip" "bastion_pup" {
  name = "kbreit-bastion-pup"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location            = azurerm_resource_group.kbreit-vwan-rg.location
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name = "kbreit-bastion"
  resource_group_name = azurerm_resource_group.kbreit-vwan-rg.name
  location            = azurerm_resource_group.kbreit-vwan-rg.location
  tunneling_enabled = true
  sku = "Standard"

  ip_configuration {
    name = "configuration"
    subnet_id = module.vnet_default.vnet_subnets[2]
    public_ip_address_id = azurerm_public_ip.bastion_pup.id
  }
}
