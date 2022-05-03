provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azurerm_resource_group" {
  name = var.azure_rg_name
  region = var.azure_rg_region
}
