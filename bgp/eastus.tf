resource "azurerm_resource_group" "kbreit_vpn_bgp_east" {
  name = "kbreit-vpn-bgp-east"
  location = "eastus"

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_east" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name
  address_space = ["10.4.0.0/16"]
  vnet_name = "vnet-east"
  subnet_prefixes = ["10.4.1.0/24"]
  subnet_names = ["GatewaySubnet"]

  tags = {
    owner = "Kevin Breit"
  }

  depends_on = [
    azurerm_resource_group.kbreit_vpn_bgp_east
  ]
}

resource "azurerm_public_ip" "vpn_gateway_ip_east" {
  name = "vpn-gateway-ip-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_east.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway_east" {
  name = "vpn-gateway-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_east.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name

  type = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp = true
  sku = "VpnGw2"
  generation = "Generation2"

  ip_configuration {
    name = "vpnGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip_east.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_east.vnet_subnets[0]
  }

  bgp_settings {
      asn = 65534
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection_east_to_central" {
  name = "connection-to-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_east.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name
  type = "Vnet2Vnet"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_east.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_central.id
  enable_bgp = true  

  shared_key = var.vpn_shared_key
}
