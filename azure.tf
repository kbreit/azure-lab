provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azurerm_resource_group" {
  name = var.azure_rg_name
  location = var.azure_rg_region

  tags = {
    owner = "Kevin Breit"
  }

}

module "vnet_default" {
  source = "Azure/network/azurerm"
  version = "3.5.0"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  address_spaces = var.azure_vnet_lz_address_spaces
  vnet_name = var.azure_vnet_lz_names
  subnet_prefixes = var.azure_vnet_lz_subnets
  subnet_names = var.azure_lz_subnet_names

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_app" {
  source = "Azure/network/azurerm"
  version = "3.5.0"
  resource_group_name =  azurerm_resource_group.azurerm_resource_group.name
  address_spaces = var.azure_vnet_app_address_spaces
  vnet_name = var.azure_vnet_app_names
  subnet_prefixes = var.azure_vnet_app_subnets
  subnet_names = var.azure_app_subnet_names
}

resource "azurerm_virtual_network_peering" "default_to_app" {
  name = "default-to-app"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  virtual_network_name =  module.vnet_default.vnet_name
  remote_virtual_network_id = module.vnet_app.vnet_name
}
