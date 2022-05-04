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
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  address_spaces = var.azure_vnet_lz_address_spaces
  vnet_name = var.azure_vnet_lz_name
  subnet_prefixes = var.azure_vnet_lz_subnets
  subnet_names = var.azure_subnet_lz_names

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_app" {
  source = "Azure/network/azurerm"
  resource_group_name =  azurerm_resource_group.azurerm_resource_group.name
  address_spaces = var.azure_vnet_app_address_spaces
  vnet_name = var.azure_vnet_app_name
  subnet_prefixes = var.azure_vnet_app_subnets
  subnet_names = var.azure_app_subnet_names
}
