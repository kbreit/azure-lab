provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "azurerm_resource_group" {
  name = "acme-dns"
}
