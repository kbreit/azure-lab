provider "azurerm" {
  features {}
}

data "azure_resource_group" "azurerm_resource_group" {
  name = "acme-dns"
}
