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
  remote_virtual_network_id = module.vnet_app.vnet_id
}

resource "azurerm_virtual_network_peering" "app_to_default" {
  name = "app-to-default"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  virtual_network_name =  module.vnet_app.vnet_name
  remote_virtual_network_id = module.vnet_default.vnet_id
}

resource "azurerm_public_ip" "vpn_gateway_ip" {
  name = "vpn-gateway-ip"
  location = azurerm_resource_group.azurerm_resource_group.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name = "vpn-gateway"
  location = azurerm_resource_group.azurerm_resource_group.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name

  type = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp = false
  sku = "Basic"

  ip_configuration {
    name = "vpnGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_default.vnet_subnets[1]
  }
}

resource "azurerm_local_network_gateway" "ep_gateway" {
  name = "ep-gateway"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location = azurerm_resource_group.azurerm_resource_group.location
  gateway_address = "34.138.95.11"
  address_space = [
    "10.207.0.0/24"
  ]
}

resource "azurerm_virtual_network_gateway_connection" "ep_vpn_connection" {
  name = "ep-connection"
  location = azurerm_resource_group.azurerm_resource_group.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name

  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id = azurerm_local_network_gateway.ep_gateway.id
}
