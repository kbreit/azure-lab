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