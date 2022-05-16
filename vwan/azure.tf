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
