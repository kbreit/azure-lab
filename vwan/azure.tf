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
