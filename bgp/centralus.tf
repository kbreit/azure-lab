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
}
