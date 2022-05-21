resource "azurerm_resource_group" "kbreit_vpn_bgp_central" {
  name = "kbreit-vpn-bgp-central"
  location = "centralus"

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_central" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  address_space = ["10.3.0.0/16"]
  vnet_name = "vnet-central"
  subnet_prefixes = ["10.3.1.0/24"]
  subnet_names = ["GatewaySubnet"]

  tags = {
    owner = "Kevin Breit"
  }

  depends_on = [
    azurerm_resource_group.kbreit_vpn_bgp_central
  ]
}

resource "azurerm_public_ip" "vpn_gateway_ip_central" {
  name = "vpn-gateway-ip-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway_central" {
  name = "vpn-gateway-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name

  type = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp = true
  sku = "VpnGw2"

  ip_configuration {
    name = "vpnGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip_central.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_central.vnet_subnets[0]
  }

  bgp_settings {
      asn = 65533
  }
}

output "vngw" {
  value = azurerm_virtual_network_gateway.vpn_gateway_central
}

resource "azurerm_local_network_gateway" "gateway_east" {
  name = "gateway-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  gateway_address = azurerm_public_ip.vpn_gateway_ip_east.ip_address
  address_space = ["10.1.2.0/24"]

  bgp_settings {
    asn = 65535
    bgp_peering_address = azurerm_virtual_network_gateway.vpn_gateway_central.bgp_settings[0].bgp_peering_addresses[0].default_addresses[0]
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection_central_to_east" {
  name = "connection-to-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_central.id
  local_network_gateway_id = azurerm_local_network_gateway.gateway_east.id

  shared_key = var.vpn_shared_key
}
